#!/bin/bash

set -e

ORG="prombot-ai"
DRY_RUN=false
YES=false

usage() {
    cat << EOF
Usage: $0 [OPTIONS]

Batch delete all forked repositories in the GitHub organization 'prombot-ai'.

OPTIONS:
    -d, --dry-run    Show what would be deleted without making changes
    -y, --yes        Skip confirmation prompt (use with caution)
    -h, --help       Show this help message

EXAMPLES:
    $0 --dry-run         # Preview what would be deleted
    $0 -y                # Delete all forks without confirmation
    $0                   # Prompt for confirmation before deleting

EOF
    exit 0
}

while [[ $# -gt 0 ]]; do
    case $1 in
        -d|--dry-run)
            DRY_RUN=true
            shift
            ;;
        -y|--yes)
            YES=true
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

# List fork repos in the org.
list_fork_full_names() {
    gh api "orgs/${ORG}/repos" \
        --method GET \
        --paginate \
        -f per_page=100 \
        -f type=forks \
        --jq '.[] | .full_name'
}

# Fetch full repo metadata to resolve parent repo display name.
get_parent_full_name() {
    local fork_full_name="$1"
    gh api "repos/${fork_full_name}" \
        --method GET \
        --jq '.parent.full_name // empty' || true
}

delete_fork() {
    local fork_full_name="$1"

    echo "Deleting fork: $fork_full_name"

    if [ "$DRY_RUN" = true ]; then
        echo "  [DRY-RUN] Would delete $fork_full_name"
        return 0
    fi

    if gh repo delete "$fork_full_name" --yes; then
        echo "  ✓ Successfully deleted $fork_full_name"
        return 0
    else
        echo "  ✗ Failed to delete $fork_full_name"
        return 1
    fi
}

echo "========================================="
echo "GitHub Fork Batch Delete for ${ORG}"
echo "========================================="
echo ""

if [ "$DRY_RUN" = true ]; then
    echo "Running in DRY-RUN mode - no changes will be made"
    echo ""
fi

# Collect all fork names first for preview
echo "Fetching fork list..."
echo ""

declare -a FORKS=()
declare -a PARENTS=()

while IFS= read -r fork_full_name; do
    if [ -z "$fork_full_name" ]; then
        continue
    fi
    FORKS+=("$fork_full_name")
    PARENTS+=("$(get_parent_full_name "$fork_full_name")")
done < <(list_fork_full_names)

total=${#FORKS[@]}

if [ "$total" -eq 0 ]; then
    echo "No fork repositories found in '${ORG}' organization."
    exit 0
fi

# Preview table
printf "%-40s %-40s\n" "FORK" "UPSTREAM"
printf "%-40s %-40s\n" "----------------------------------------" "----------------------------------------"
for i in "${!FORKS[@]}"; do
    printf "%-40s %-40s\n" "${FORKS[$i]}" "${PARENTS[$i]:-(unknown)}"
done

echo ""
echo "Total forks found: $total"
echo ""

# Confirmation
if [ "$DRY_RUN" = false ] && [ "$YES" = false ]; then
    read -r -p "Are you sure you want to permanently delete all $total fork repositories? Type 'yes' to confirm: " answer
    echo ""
    if [ "$answer" != "yes" ]; then
        echo "Aborted. No forks were deleted."
        exit 0
    fi
fi

# Perform deletion
success=0
failed=0

for i in "${!FORKS[@]}"; do
    fork_full_name="${FORKS[$i]}"
    parent_repo="${PARENTS[$i]}"

    echo "[$((i + 1))/$total] $fork_full_name"
    if [ -n "$parent_repo" ]; then
        echo "  Upstream: $parent_repo"
    fi

    if delete_fork "$fork_full_name"; then
        success=$((success + 1))
    else
        failed=$((failed + 1))
    fi

    echo ""
done

echo "========================================="
echo "Delete Summary"
echo "========================================="
echo "Total forks processed: $total"
echo "Successful: $success"
echo "Failed: $failed"
echo ""

if [ $failed -gt 0 ]; then
    exit 1
fi
