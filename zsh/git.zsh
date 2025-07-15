#!/bin/bash

# Description: This script provides custom Git log and branch formatting.

# Log Format Configuration
LOG_HASH="%C(always,yellow)%h%C(always,reset)"
LOG_RELATIVE_TIME="%C(always,green)(%ar)%C(always,reset)"
LOG_AUTHOR="%C(always,blue)<%an>%C(always,reset)"
LOG_REFS="%C(always,red)%d%C(always,reset)"
LOG_SUBJECT="%s"

LOG_FORMAT="$LOG_HASH}$LOG_AUTHOR}$LOG_RELATIVE_TIME}$LOG_SUBJECT $LOG_REFS"

# Branch Format Configuration
BRANCH_PREFIX="%(HEAD)"
BRANCH_REF="%(color:red)%(color:bold)%(refname:short)%(color:reset)"
BRANCH_HASH="%(color:yellow)%(objectname:short)%(color:reset)"
BRANCH_DATE="%(color:green)(%(committerdate:relative))%(color:reset)"
BRANCH_AUTHOR="%(color:blue)%(color:bold)<%(authorname)>%(color:reset)"
BRANCH_CONTENTS="%(contents:subject)"
BRANCH_FORMAT="}$BRANCH_PREFIX}$BRANCH_REF}$BRANCH_HASH}$BRANCH_DATE}$BRANCH_AUTHOR}$BRANCH_CONTENTS"

# Format git output with shortened time units and columnized display
pretty_git_format() {
    sed -Ee 's/(^[^)]*) ago\)/\1)/' \
        -Ee 's/(^[^)]*), [[:digit:]]+ .*months?\)/\1)/' \
        -Ee 's/ seconds?\)/s\)/' \
        -Ee 's/ minutes?\)/m\)/' \
        -Ee 's/ hours?\)/h\)/' \
        -Ee 's/ days?\)/d\)/' \
        -Ee 's/ weeks?\)/w\)/' \
        -Ee 's/ months?\)/M\)/' \
        -Ee 's/<Noe Sanchez>/<me>/' \
        -Ee 's/<([^ >]+) [^>]*>/<\1>/' \
                                 | column -s '}' -t
}

# Handle paging for git output based on GIT_NO_PAGER env var
git_page_maybe() {
    if [ -n "${GIT_NO_PAGER}" ]; then
        cat
    else
        less --quit-if-one-screen --no-init --RAW-CONTROL-CHARS --chop-long-lines
    fi
}

# Show formatted git log for last 12 months with graph
pretty_git_log() {
    git log --since="12 months ago" --graph --pretty="tformat:${LOG_FORMAT}" "$@" | pretty_git_format | git_page_maybe
}

# Show formatted git log for all branches from last 12 months
pretty_git_log_all() {
    git log --all --since="12 months ago" --graph --pretty="tformat:${LOG_FORMAT}" "$@" | pretty_git_format | git_page_maybe
}

# Display formatted branch list with commit info
pretty_git_branch() {
    git branch -v --color=always --format=${BRANCH_FORMAT} "$@" | pretty_git_format
}

# Display formatted branch list sorted by commit date
pretty_git_branch_sorted() {
    git branch -v --color=always --format=${BRANCH_FORMAT} --sort=-committerdate "$@" | pretty_git_format
}

# Get current branch name
git_current_branch() {
    git rev-parse --abbrev-ref HEAD
}

# AI Functions

# Generate conventional commit message using OpenAI API from git diff
generate_ai_commit_message() {
    local diff="${1:-$(cat)}"

    if [ -z "$OPENAI_API_KEY" ]; then
        echo "Error: OPENAI_API_KEY not set" >&2
        return 1
    fi

    local clean_diff=$(echo "$diff" | tr -d '\000-\031')
    local prompt="Generate a conventional commit message for this git diff. Format: type(scope): description. Be concise.\n\n$clean_diff"

    curl -s -X POST "https://api.openai.com/v1/chat/completions" \
        -H "Content-Type: application/json" \
        -H "Authorization: Bearer $OPENAI_API_KEY" \
        -d "$(jq -n \
            --arg prompt "$prompt" \
            '{
                model: "gpt-4o",
                messages: [
                    {role: "system", content: "You are a git commit message generator. Follow conventional commits format. Be concise and descriptive."},
                    {role: "user", content: $prompt}
                ],
                max_tokens: 80,
                temperature: 0.3
            }')" | jq -r '.choices[0].message.content // empty'
}

# Get clean commit list between current branch and target branch
get_git_commits_clean() {
    local target_branch="$1"
    local current_branch=$(git_current_branch)
    git log --oneline "origin/$target_branch..$current_branch" 2> /dev/null | head -5 || git log --oneline -5
}

# Generate PR title and description using OpenAI API from commits and diff
generate_ai_pr_description() {
    local input="${1:-$(cat)}"

    if [ -z "$OPENAI_API_KEY" ]; then
        echo "Error: OPENAI_API_KEY not set" >&2
        return 1
    fi

    local clean_input=$(echo "$input" | sed 's/\x1b\[[0-9;]*m//g' | tr -d '\000-\031')
    local prompt="Generate a semantic PR title and description.\n\nFormat:\n## Title\n[type(scope): short semantic title]\n\n## Summary\n[Brief description of what this PR accomplishes]\n\n## Changes\n- [Key changes made]\n\n## Testing\n- [How to test this]\n\nKeep title under 50 chars. Be professional and concise.\n\nContext:\n$clean_input"

    curl -s -X POST "https://api.openai.com/v1/chat/completions" \
        -H "Content-Type: application/json" \
        -H "Authorization: Bearer $OPENAI_API_KEY" \
        -d "$(jq -n \
            --arg prompt "$prompt" \
            '{
                model: "gpt-4o",
                messages: [
                    {role: "system", content: "You are a senior developer writing PR descriptions. Be concise, professional, and focus on what matters to reviewers."},
                    {role: "user", content: $prompt}
                ],
                max_tokens: 300,
                temperature: 0.3
            }')" | jq -r '.choices[0].message.content // empty'
}

# Create GitHub PR using GitHub API with title, body, and branch info
create_github_pr() {
    local title="$1"
    local body="$2"
    local base_branch="$3"
    local head_branch="$4"

    if [ -z "$GITHUB_TOKEN" ]; then
        echo "Error: GITHUB_TOKEN not set" >&2
        return 1
    fi

    local repo_url=$(git remote get-url origin)
    local repo_info=$(echo "$repo_url" | sed -E 's/.*github\.com[\/:]([^\/]+)\/([^\/]+)(\.git)?$/\1\/\2/' | sed 's/\.git$//')

    if [ -z "$repo_info" ]; then
        echo "Error: Could not parse GitHub repository from remote" >&2
        return 1
    fi

    echo "Creating PR for: $repo_info"
    echo "From: $head_branch → $base_branch"
    echo "Title: $title"

    if ! git ls-remote --heads origin "$head_branch" | grep -q "$head_branch"; then
        echo "❌ Branch $head_branch not found in remote. Push first:"
        echo "git push -u origin $head_branch"
        return 1
    fi

    if [ -z "$body" ]; then
        body="Auto-generated PR description"
    fi

    local response=$(curl -s -X POST "https://api.github.com/repos/$repo_info/pulls" \
        -H "Authorization: token $GITHUB_TOKEN" \
        -H "Accept: application/vnd.github.v3+json" \
        -H "Content-Type: application/json" \
        -d "$(jq -n \
            --arg title "$title" \
            --arg body "$body" \
            --arg head "$head_branch" \
            --arg base "$base_branch" \
            '{
                title: $title,
                body: $body,
                head: $head,
                base: $base
            }')")

    local pr_url=$(echo "$response" | jq -r '.html_url // empty' 2> /dev/null)
    local pr_number=$(echo "$response" | jq -r '.number // empty' 2> /dev/null)
    local error_message=$(echo "$response" | jq -r '.message // empty' 2> /dev/null)

    if [ -n "$pr_url" ] && [ "$pr_url" != "null" ] && [ "$pr_url" != "empty" ]; then
        echo "✅ PR #$pr_number created: $pr_url"
        return 0
    elif [ -n "$error_message" ] && [ "$error_message" != "null" ] && [ "$error_message" != "empty" ]; then
        echo "❌ Failed to create PR: $error_message"
        return 1
    else
        if echo "$response" | grep -q '"html_url"'; then
            local manual_url=$(echo "$response" | grep -o '"html_url":"[^"]*' | cut -d'"' -f4)
            local manual_number=$(echo "$response" | grep -o '"number":[0-9]*' | cut -d':' -f2)
            echo "✅ PR #$manual_number created: $manual_url"
            return 0
        else
            echo "❌ Failed to create PR - unknown error"
            echo "Response: $response"
            return 1
        fi
    fi
}

# Main Functions

# Get git diff of staged changes (ready for commit)
get_git_staged_diff() {
    git diff --cached --no-color
}

# Interactive workflow: generate AI commit message and prompt user to commit
interactive_ai_commit() {
    if ! git rev-parse --git-dir > /dev/null 2>&1; then
        echo "Not in a git repository" >&2
        return 1
    fi

    local diff=$(get_git_staged_diff)

    if [ -z "$diff" ]; then
        echo "No staged changes. Stage with: git add ."
        return 1
    fi

    echo "Generating commit message..."
    local msg=$(echo "$diff" | generate_ai_commit_message)

    if [ -z "$msg" ]; then
        echo "Failed to generate commit message"
        return 1
    fi

    echo "AI suggests: $msg"
    echo -n "Use this message? [y/N] "
    read -r response

    if [[ "$response" =~ ^[Yy]$ ]]; then
        git commit -m "$msg"
        echo "Committed successfully!"
    else
        echo "Aborted."
    fi
}

# Show AI-generated commit message for staged changes without committing
show_ai_commit_message() {
    get_git_staged_diff | generate_ai_commit_message
}

# Determine default target branch (main or master) from remote
get_default_target_branch() {
    if git show-ref --verify --quiet refs/remotes/origin/main; then
        echo "main"
    elif git show-ref --verify --quiet refs/remotes/origin/master; then
        echo "master"
    else
        echo "main"
    fi
}

# Interactive branch selection using fzf with default fallback
select_target_branch() {
    local default_branch=$(get_default_target_branch)
    local selected_branch=$(git branch -r | grep -v HEAD | sed 's/origin\///' | sed 's/^[ \t]*//' | sort -u | fzf --prompt="Select target branch: " --header="Default: $default_branch" --height=40%)
    echo "${selected_branch:-$default_branch}"
}

# Get git diff between current branch and target branch
get_git_branch_diff() {
    local target_branch="$1"
    local current_branch=$(git_current_branch)
    git diff --no-color "origin/$target_branch..$current_branch" 2> /dev/null || git diff --no-color HEAD~1
}

# Interactive workflow: generate AI PR description and create GitHub PR
interactive_ai_pr() {
    if ! git rev-parse --git-dir > /dev/null 2>&1; then
        echo "Not in a git repository" >&2
        return 1
    fi

    local current_branch=$(git_current_branch)
    local target_branch=$(select_target_branch)

    if [ -z "$target_branch" ]; then
        echo "No target branch selected" >&2
        return 1
    fi

    local commits=$(get_git_commits_clean "$target_branch")
    local diff=$(get_git_branch_diff "$target_branch")

    if [ -z "$commits" ] && [ -z "$diff" ]; then
        echo "No changes found for PR"
        return 1
    fi

    local input="Branch: $current_branch → $target_branch\n\nCommits:\n$commits\n\nDiff:\n$diff"

    echo "Generating PR description..."
    local description=$(echo -e "$input" | generate_ai_pr_description)

    if [ -z "$description" ]; then
        echo "Failed to generate PR description"
        return 1
    fi

    echo "$description"
    echo -n "Create PR to $target_branch? [y/N] "
    read -r response

    if [[ "$response" =~ ^[Yy]$ ]]; then
        local title=$(echo "$description" | grep -A1 "^## Title" | tail -1 | sed 's/^[[:space:]]*//' | sed 's/^\[//' | sed 's/\]$//')
        local body=$(echo "$description" | sed '/^## Title$/,+1d')

        if [ -z "$title" ]; then
            title="feat: $(echo "$current_branch" | cut -d'/' -f2- | sed 's/-/ /g')"
        fi

        create_github_pr "$title" "$body" "$target_branch" "$current_branch"
    fi
}

# Show AI-generated PR description for current branch without creating PR
show_ai_pr_description() {
    local current_branch=$(git_current_branch)
    local target_branch=$(get_default_target_branch)
    local commits=$(get_git_commits_clean "$target_branch")
    local diff=$(get_git_branch_diff "$target_branch")
    local input="Branch: $current_branch → $target_branch\n\nCommits:\n$commits\n\nDiff:\n$diff"
    echo -e "$input" | generate_ai_pr_description
}
