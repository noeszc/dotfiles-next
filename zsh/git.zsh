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

# Function to Display Git HEAD
show_git_head() {
    pretty_git_log -1
    git show -p --pretty="tformat:"
}

# Function to Display Pretty Git Log
pretty_git_log() {
    git log --since="12 months ago" --graph --pretty="tformat:${LOG_FORMAT}" $* | pretty_git_format | git_page_maybe
}

# Function to Display Pretty Git Log for All Branches
pretty_git_log_all() {
    git log --all --since="12 months ago" --graph --pretty="tformat:${LOG_FORMAT}" $* | pretty_git_format | git_page_maybe
}

# Function to Display Pretty Git Branch
pretty_git_branch() {
    git branch -v --color=always --format=${BRANCH_FORMAT} $* | pretty_git_format
}

# Function to Display Pretty Git Branch (Sorted by Committer Date)
pretty_git_branch_sorted() {
    git branch -v --color=always --format=${BRANCH_FORMAT} --sort=-committerdate $* | pretty_git_format
}

# Function to Format Git Log Output
pretty_git_format() {
    # Replace (2 years ago) with (2 years)
    sed -Ee 's/(^[^)]*) ago\)/\1)/' |
    # Replace (2 years, 5 months) with (2 years)
    sed -Ee 's/(^[^)]*), [[:digit:]]+ .*months?\)/\1)/' |
    # Shorten time units
    sed -Ee 's/ seconds?\)/s\)/' |
    sed -Ee 's/ minutes?\)/m\)/' |
    sed -Ee 's/ hours?\)/h\)/' |
    sed -Ee 's/ days?\)/d\)/' |
    sed -Ee 's/ weeks?\)/w\)/' |
    sed -Ee 's/ months?\)/M\)/' |
    # Shorten author names
    sed -Ee 's/<Noe Sanchez>/<me>/' |
    sed -Ee 's/<([^ >]+) [^>]*>/<\1>/' |
    # Format columns using '}' delimiter
    column -s '}' -t
}

# Function to Page Git Output
git_page_maybe() {
    # Page only if not explicitly disabled.
    if [ -n "${GIT_NO_PAGER}" ]; then
        cat
    else
        # Page only if needed.
        less --quit-if-one-screen --no-init --RAW-CONTROL-CHARS --chop-long-lines
    fi
}

# AI-powered Git Functions
generate_ai_commit_message() {
    local diff="${1:-$(cat)}"
    
    if [ -z "$OPENAI_API_KEY" ]; then
        echo "Error: OPENAI_API_KEY not set" >&2
        return 1
    fi
    
    local escaped_diff=$(echo "$diff" | jq -Rs .)
    local system_prompt="You are a git commit message generator. Follow conventional commits format. Be concise and descriptive."
    local user_prompt="Generate a conventional commit message for this git diff. Format: type(scope): description. Be concise.\n\n$diff"
    local escaped_user_prompt=$(echo "$user_prompt" | jq -Rs .)
    
    curl -s -X POST "https://api.openai.com/v1/chat/completions" \
        -H "Content-Type: application/json" \
        -H "Authorization: Bearer $OPENAI_API_KEY" \
        -d "{
            \"model\": \"gpt-4o-mini\",
            \"messages\": [
                {\"role\": \"system\", \"content\": $(echo "$system_prompt" | jq -Rs .)},
                {\"role\": \"user\", \"content\": $escaped_user_prompt}
            ],
            \"max_tokens\": 80,
            \"temperature\": 0.3
        }" | jq -r '.choices[0].message.content // empty'
}

get_git_staged_diff() {
    git diff --cached --no-color
}

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

show_ai_commit_message() {
    get_git_staged_diff | generate_ai_commit_message
}

debug_ai_commit() {
    local diff=$(get_git_staged_diff)
    
    echo "=== DEBUG ==="
    echo "API Key set: ${OPENAI_API_KEY:+YES}"
    echo "Diff length: ${#diff}"
    echo "First 100 chars of diff:"
    echo "${diff:0:100}"
    echo "============="
    
    # Probar la API call
    local response=$(echo "$diff" | generate_ai_commit_message)
    echo "API Response: '$response'"
}

debug_ai_commit_deep() {
    local diff=$(get_git_staged_diff)
    local prompt="Generate a conventional commit message for this git diff. Format: type(scope): description. Be concise.\n\n$diff"
    
    echo "=== DEEP DEBUG ==="
    echo "Calling OpenAI API..."
    
    # Llamada con debug completo
    local full_response=$(curl -s -X POST "https://api.openai.com/v1/chat/completions" \
        -H "Content-Type: application/json" \
        -H "Authorization: Bearer $OPENAI_API_KEY" \
        -d "{
            \"model\": \"gpt-4o-mini\",
            \"messages\": [
                {\"role\": \"system\", \"content\": \"You are a git commit message generator. Follow conventional commits format. Be concise and descriptive.\"},
                {\"role\": \"user\", \"content\": \"$prompt\"}
            ],
            \"max_tokens\": 80,
            \"temperature\": 0.3
        }")
    
    echo "Full API Response:"
    echo "$full_response"
    echo "=================="
    
    # Probar el parsing
    local parsed=$(echo "$full_response" | jq -r '.choices[0].message.content // empty')
    echo "Parsed message: '$parsed'"
    echo "=================="
}
