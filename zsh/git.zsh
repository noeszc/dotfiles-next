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
    local temp="${TEMP:-0.7}"

    if [ -z "$OPENAI_API_KEY" ]; then
        echo "Error: OPENAI_API_KEY not set" >&2
        return 1
    fi

    # Obtener contexto del repositorio
    local repo_name=$(basename $(git rev-parse --show-toplevel 2>/dev/null) 2>/dev/null || echo "unknown")
    local branch_name=$(git_current_branch 2>/dev/null || echo "unknown")
    local files_changed=$(echo "$diff" | grep "^diff --git" | wc -l | tr -d ' ')

    # Analizar tipos de archivos modificados
    local file_types=$(echo "$diff" | grep "^diff --git" | sed 's/.*\///' | sed 's/.*\.//' | sort | uniq -c | sort -rn | head -3)

    # Detectar patrones comunes
    local has_tests=$(echo "$diff" | grep -q "test\|spec" && echo "true" || echo "false")
    local has_config=$(echo "$diff" | grep -q "config\|\.json\|\.yml\|\.yaml" && echo "true" || echo "false")
    local has_docs=$(echo "$diff" | grep -q "README\|\.md\|docs/" && echo "true" || echo "false")

    local clean_diff=$(echo "$diff" | tr -d '\000-\031' | head -c 8000)  # Limitar tamaño

    local system_prompt="You are an expert senior developer writing conventional commit messages.

RULES:
- Format: type(scope): description
- Types: feat, fix, refactor, style, test, docs, chore, perf
- Scope: specific component/module affected (e.g., auth, api, ui, tags)
- Description: present tense, no period, under 50 chars total
- Focus on WHAT changed and business impact, not HOW

ANALYSIS APPROACH:
1. Identify the main functionality changed
2. Determine the appropriate scope from file paths
3. Choose type based on change impact:
   - feat: new functionality
   - fix: bug corrections
   - refactor: code restructuring without behavior change
   - style: formatting, linting fixes
   - test: adding/updating tests
   - docs: documentation changes
   - chore: tooling, dependencies, config
   - perf: performance improvements

Be specific and descriptive while staying concise."

    local user_prompt="Repository: $repo_name
Branch: $branch_name
Files changed: $files_changed
File types: $file_types
Has tests: $has_tests
Has config: $has_config
Has docs: $has_docs

Generate a conventional commit message for this change:

$clean_diff"

    curl -s -X POST "https://api.openai.com/v1/chat/completions" \
        -H "Content-Type: application/json" \
        -H "Authorization: Bearer $OPENAI_API_KEY" \
        -d "$(jq -n \
            --arg system "$system_prompt" \
            --arg user "$user_prompt" \
            --argjson temp "$temp" \
            '{
                model: "gpt-4o-mini",
                messages: [
                    {role: "system", content: $system},
                    {role: "user", content: $user}
                ],
                max_tokens: 60,
                temperature: $temp
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
    local linear_id="${2:-}"

    if [ -z "$OPENAI_API_KEY" ]; then
        echo "Error: OPENAI_API_KEY not set" >&2
        return 1
    fi

    # Obtener más contexto del repositorio
    local repo_name=$(basename $(git rev-parse --show-toplevel 2>/dev/null) 2>/dev/null || echo "unknown")
    local current_branch=$(git_current_branch 2>/dev/null || echo "unknown")
    local clean_input=$(echo "$input" | sed 's/\x1b\[[0-9;]*m//g' | tr -d '\000-\031' | head -c 12000)

    # Extraer información específica
    local files_changed=$(echo "$clean_input" | grep -c "^diff --git" || echo "0")
    local additions=$(echo "$clean_input" | grep "^+" | wc -l | tr -d ' ')
    local deletions=$(echo "$clean_input" | grep "^-" | wc -l | tr -d ' ')

    # Preparar información de Linear si se proporciona
    local linear_info=""
    local linear_footer=""
    if [ -n "$linear_id" ]; then
        linear_info="Linear Issue: $linear_id"
        linear_footer="

Closes $linear_id"
    fi

    local system_prompt="You are a senior engineering manager reviewing code changes for PR descriptions.

CRITICAL RULES:
- NEVER invent or mention ticket IDs, Jira issues, or tracking numbers
- NEVER add closes/fixes statements unless specifically provided
- Focus only on the actual code changes shown
- Be factual and specific about what the code does
- Do not make assumptions about project management tools

REQUIREMENTS:
- Write professional, technical PR descriptions
- Focus on business value and technical impact
- Use present tense for descriptions
- Be specific about what changed and why
- Include testing considerations
- Use conventional commit format for title
- Title should be under 50 characters and descriptive

STRUCTURE:
## Title
[type(scope): concise description under 50 chars]

## Summary
[2-3 sentences explaining what this PR accomplishes and why]

## Changes
- [Specific technical changes made]
- [Focus on functionality, components affected]

## Testing
- [How to verify the changes work]
- [Edge cases to consider]

## Impact
- [Who this affects (users, developers)]
- [Any considerations for reviewers]"

    local user_prompt="Repository: $repo_name
Branch: $current_branch
Files changed: $files_changed
Lines added: $additions
Lines deleted: $deletions
$linear_info

Analyze the following changes and create a comprehensive PR description:

$clean_input"

    local description=$(curl -s -X POST "https://api.openai.com/v1/chat/completions" \
        -H "Content-Type: application/json" \
        -H "Authorization: Bearer $OPENAI_API_KEY" \
        -d "$(jq -n \
            --arg system "$system_prompt" \
            --arg user "$user_prompt" \
            '{
                model: "gpt-4o",
                messages: [
                    {role: "system", content: $system},
                    {role: "user", content: $user}
                ],
                max_tokens: 500,
                temperature: 0.6
            }')" | jq -r '.choices[0].message.content // empty')

    # Añadir Linear footer si se proporcionó
    echo "$description$linear_footer"
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

    # Preguntar por Linear ID opcional
    echo -n "Linear Issue ID (optional, press Enter to skip): "
    read -r linear_id

    # Limpiar el input - solo permitir formato tipo ABC-123
    if [ -n "$linear_id" ]; then
        linear_id=$(echo "$linear_id" | sed 's/^[[:space:]]*//' | sed 's/[[:space:]]*$//')
        if ! echo "$linear_id" | grep -qE "^[A-Z]+-[0-9]+$"; then
            echo "⚠️  Linear ID format should be like ABC-123, using it as-is: $linear_id"
        fi
    fi

    local commits=$(get_git_commits_clean "$target_branch")
    local diff=$(get_git_branch_diff "$target_branch")

    if [ -z "$commits" ] && [ -z "$diff" ]; then
        echo "No changes found for PR"
        return 1
    fi

    local input="Branch: $current_branch → $target_branch\n\nCommits:\n$commits\n\nDiff:\n$diff"

    echo "Generating PR description..."
    if [ -n "$linear_id" ]; then
        echo "📋 Including Linear issue: $linear_id"
    fi

    local description=$(echo -e "$input" | generate_ai_pr_description "" "$linear_id")

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

    # Preguntar por Linear ID opcional
    echo -n "Linear Issue ID (optional, press Enter to skip): "
    read -r linear_id

    # Limpiar el input
    if [ -n "$linear_id" ]; then
        linear_id=$(echo "$linear_id" | sed 's/^[[:space:]]*//' | sed 's/[[:space:]]*$//')
        if ! echo "$linear_id" | grep -qE "^[A-Z]+-[0-9]+$"; then
            echo "⚠️  Linear ID format should be like ABC-123, using it as-is: $linear_id"
        fi
    fi

    local commits=$(get_git_commits_clean "$target_branch")
    local diff=$(get_git_branch_diff "$target_branch")
    local input="Branch: $current_branch → $target_branch\n\nCommits:\n$commits\n\nDiff:\n$diff"
    echo -e "$input" | generate_ai_pr_description "" "$linear_id"
}

# Git push current branch with upstream and optional PR opening
git_push_current() {
    local current_branch=$(git_current_branch)

    if ! git rev-parse --git-dir > /dev/null 2>&1; then
        echo "Not in a git repository" >&2
        return 1
    fi

    echo "Pushing branch: $current_branch"

    if git push -u origin HEAD; then
        echo "Successfully pushed $current_branch"

        if [[ "$1" == "--open" ]] || [[ "$1" == "-o" ]]; then
            local pr_url=$(git push -u origin HEAD 2>&1 | grep "pull/new" | awk '{print $2}')
            if [[ -n "$pr_url" ]]; then
                echo "Opening PR: $pr_url"
                open "$pr_url"
            else
                echo "No PR URL found (branch might already exist on remote)"
            fi
        fi
    else
        echo "Failed to push $current_branch"
        return 1
    fi
}

# Enhanced AI Functions

# Interactive workflow: generate multiple AI commit message options
interactive_ai_commit_with_options() {
    if ! git rev-parse --git-dir > /dev/null 2>&1; then
        echo "Not in a git repository" >&2
        return 1
    fi

    local diff=$(get_git_staged_diff)
    if [ -z "$diff" ]; then
        echo "No staged changes. Stage with: git add ."
        return 1
    fi

    echo "Generating commit message options..."

    # Generar 3 opciones con temperaturas distintas
    local msg1=$(TEMP=0.3 echo "$diff" | generate_ai_commit_message)
    local msg2=$(TEMP=0.7 echo "$diff" | generate_ai_commit_message)
    local msg3=$(TEMP=0.9 echo "$diff" | generate_ai_commit_message)

    echo "Choose a commit message:"
    echo "1) $msg1"
    echo "2) $msg2"
    echo "3) $msg3"
    echo "4) Enter custom message"
    echo -n "Select option [1-4]: "

    read -r choice
    case $choice in
        1) selected_msg="$msg1" ;;
        2) selected_msg="$msg2" ;;
        3) selected_msg="$msg3" ;;
        4) echo -n "Enter commit message: "; read -r selected_msg ;;
        *) echo "Invalid choice"; return 1 ;;
    esac

    if [ -n "$selected_msg" ]; then
        analyze_commit_quality "$selected_msg"
        echo -n "Use this message? [y/N] "
        read -r response
        if [[ "$response" =~ ^[Yy]$ ]]; then
            git commit -m "$selected_msg"
            echo "Committed successfully with: $selected_msg"
        fi
    fi
}

# Analyze commit message quality and provide score
analyze_commit_quality() {
    local message="$1"

    local score=0
    local feedback=""

    # Verificar formato convencional
    if echo "$message" | grep -qE "^(feat|fix|docs|style|refactor|test|chore|perf)(\(.+\))?: .+"; then
        score=$((score + 30))
        feedback="$feedback\n✅ Conventional commit format"
    else
        feedback="$feedback\n❌ No conventional commit format"
    fi

    # Verificar longitud
    if [ ${#message} -le 50 ]; then
        score=$((score + 20))
        feedback="$feedback\n✅ Good length (${#message} chars)"
    else
        feedback="$feedback\n⚠️ Message too long (${#message} chars)"
    fi

    # Verificar scope
    if echo "$message" | grep -q "(.*):"; then
        score=$((score + 20))
        feedback="$feedback\n✅ Has scope"
    else
        feedback="$feedback\n⚠️ Consider adding scope"
    fi

    # Verificar descripción
    if echo "$message" | grep -qE ": [a-z]"; then
        score=$((score + 15))
        feedback="$feedback\n✅ Lowercase description"
    fi

    # Verificar que no termine en punto
    if ! echo "$message" | grep -q "\.$"; then
        score=$((score + 15))
        feedback="$feedback\n✅ No period at end"
    fi

    echo "Quality Score: $score/100"
    echo -e "$feedback"
}

# Show commit statistics for current branch vs target
show_commit_stats() {
    local target_branch="${1:-$(get_default_target_branch)}"
    local current_branch=$(git_current_branch)

    echo "Branch: $current_branch → $target_branch"
    echo "=========================="

    local commits=$(git rev-list --count "origin/$target_branch..$current_branch" 2>/dev/null || echo "0")
    local files=$(git diff --name-only "origin/$target_branch..$current_branch" 2>/dev/null | wc -l | tr -d ' ')
    local additions=$(git diff --shortstat "origin/$target_branch..$current_branch" 2>/dev/null | awk '{print $4}' || echo "0")
    local deletions=$(git diff --shortstat "origin/$target_branch..$current_branch" 2>/dev/null | awk '{print $6}' || echo "0")

    echo "Commits: $commits"
    echo "Files changed: $files"
    echo "Lines added: +$additions"
    echo "Lines deleted: -$deletions"

    # Mostrar tipos de archivos modificados
    local file_types=$(git diff --name-only "origin/$target_branch..$current_branch" 2>/dev/null | sed 's/.*\.//' | sort | uniq -c | sort -rn | head -5)
    if [ -n "$file_types" ]; then
        echo ""
        echo "File types modified:"
        echo "$file_types"
    fi
}

# Quick commit with AI assistance (stage all and commit)
quick_ai_commit() {
    if ! git rev-parse --git-dir > /dev/null 2>&1; then
        echo "Not in a git repository" >&2
        return 1
    fi

    # Stage all changes
    git add .

    local diff=$(get_git_staged_diff)
    if [ -z "$diff" ]; then
        echo "No changes to commit"
        return 1
    fi

    echo "Staging all changes and generating commit message..."
    local msg=$(echo "$diff" | generate_ai_commit_message)

    if [ -z "$msg" ]; then
        echo "Failed to generate commit message"
        return 1
    fi

    analyze_commit_quality "$msg"
    echo -n "Commit with: '$msg'? [y/N] "
    read -r response

    if [[ "$response" =~ ^[Yy]$ ]]; then
        git commit -m "$msg"
        echo "✅ Committed successfully!"
    else
        echo "Aborted."
    fi
}
