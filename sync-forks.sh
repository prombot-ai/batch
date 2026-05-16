#!/bin/bash

set -e

ORG="prombot-ai"
DRY_RUN=false
FORCE=false

usage() {
    cat << EOF
Usage: $0 [OPTIONS]

Sync all fork repositories in the GitHub organization 'prombot-ai'.

OPTIONS:
    -d, --dry-run    Show what would be synced without making changes
    -f, --force      Force sync even if already up to date
    -h, --help       Show this help message

EXAMPLES:
    $0                   # Sync all forks
    $0 --dry-run         # Preview what would be synced
    $0 --force           # Force sync all forks

EOF
    exit 0
}

while [[ $# -gt 0 ]]; do
    case $1 in
        -d|--dry-run)
            DRY_RUN=true
            shift
            ;;
        -f|--force)
            FORCE=true
            shift
            ;;
        -h|--help)
            usage
            ;;
        *)
            echo "Unknown option: $1"
            usage
            ;;
    esac
done

if [ -z "$GITHUB_TOKEN" ]; then
    echo "Error: GITHUB_TOKEN environment variable is not set"
    echo "Please set your GitHub Personal Access Token:"
    echo "  export GITHUB_TOKEN=your_token_here"
    exit 1
fi

get_forks() {
    local page=1
    local per_page=100
    
    while true; do
        local response=$(gh api "orgs/${ORG}/repos" \
            --paginate \
            --jq "[.[] | select(.fork == true) | {name: .name, full_name: .full_name, parent: .parent.full_name}]" \
            -F page="$page" \
            -F per_page="$per_page" 2>/dev/null)
        
        if [ -z "$response" ] || [ "$response" = "[]" ]; then
            break
        fi
        
        echo "$response" | jq -r '.[] | "\(.full_name)|\(.parent)"'
        
        page=$((page + 1))
        
        local next_page=$(echo "$response" | jq -r 'length')
        if [ "$next_page" -lt "$per_page" ]; then
            break
        fi
    done
}

sync_fork() {
    local fork_full_name="$1"
    local parent_repo="$2"
    
    echo "Syncing fork: $fork_full_name"
    echo "  From parent: $parent_repo"
    
    if [ "$DRY_RUN" = true ]; then
        echo "  [DRY-RUN] Would sync $fork_full_name from $parent_repo"
        return 0
    fi
    
    local sync_args=("$fork_full_name" "-s" "$parent_repo")
    
    if [ "$FORCE" = true ]; then
        sync_args+=("--force")
    fi
    
    if gh repo sync "${sync_args[@]}"; then
        echo "  ✓ Successfully synced $fork_full_name"
        return 0
    else
        echo "  ✗ Failed to sync $fork_full_name"
        return 1
    fi
}

echo "========================================="
echo "GitHub Fork Batch Sync for ${ORG}"
echo "========================================="
echo ""

if [ "$DRY_RUN" = true ]; then
    echo "Running in DRY-RUN mode - no changes will be made"
    echo ""
fi

total=0
success=0
failed=0

while IFS='|' read -r fork_full_name parent_repo; do
    if [ -z "$fork_full_name" ]; then
        continue
    fi
    
    total=$((total + 1))
    
    if sync_fork "$fork_full_name" "$parent_repo"; then
        success=$((success + 1))
    else
        failed=$((failed + 1))
    fi
    
    echo ""
    
done < <(get_forks)

echo "========================================="
echo "Sync Summary"
echo "========================================="
echo "Total forks processed: $total"
echo "Successful: $success"
echo "Failed: $failed"
echo ""

if [ $failed -gt 0 ]; then
    exit 1
fi
