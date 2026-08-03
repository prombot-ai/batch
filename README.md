# GitHub Fork Batch Tools

Batch manage fork repositories in the `prombot-ai` GitHub organization.

## Scripts

| Script | Description |
|--------|-------------|
| `sync-forks.sh` | Batch sync all fork repositories with upstream |
| `delete-forks.sh` | Batch delete all fork repositories |

## Common Features

- Automatically fetch all fork repositories in the organization
- Dry Run mode support for safe preview
- Automatic pagination for large numbers of repositories
- Detailed execution logs and statistics

## Prerequisites

### 1. Install GitHub CLI

**Ubuntu/Debian:**
```bash
sudo apt install gh
```

**macOS:**
```bash
brew install gh
```

**Or download from [GitHub CLI official website](https://cli.github.com/)**

### 2. Authenticate GitHub CLI

```bash
gh auth login
```

### 3. Set GitHub Token

```bash
export GITHUB_TOKEN="your_github_pat_token"
```

It's recommended to add the token to environment variables or config files to avoid setting it manually each time.

## Usage

### sync-forks.sh

```bash
# Basic usage - sync all forks
./sync-forks.sh

# Dry Run mode - preview what would be synced (no actual changes)
./sync-forks.sh --dry-run

# Force sync - execute even if already up to date
./sync-forks.sh --force

# Show help
./sync-forks.sh --help
```

| Parameter | Description |
|-----------|-------------|
| `-d, --dry-run` | Preview mode, shows what would be synced without making changes |
| `-f, --force` | Force sync, execute even if fork is already in sync with upstream |
| `-h, --help` | Show help information |

### delete-forks.sh

```bash
# Dry Run mode - preview what would be deleted (no actual changes)
./delete-forks.sh --dry-run

# Interactive mode - prompt for confirmation before deleting
./delete-forks.sh

# Skip confirmation - delete all forks immediately
./delete-forks.sh --yes

# Show help
./delete-forks.sh --help
```

| Parameter | Description |
|-----------|-------------|
| `-d, --dry-run` | Preview mode, shows what would be deleted without making changes |
| `-y, --yes`   | Skip confirmation prompt (use with caution) |
| `-h, --help`  | Show help information |

## How It Works

### sync-forks.sh

1. Use GitHub API to fetch all fork repositories in the specified organization
2. For each fork, identify its upstream repository (parent repository)
3. Use `gh repo sync` command to sync updates from upstream to the fork
4. Record success/failure status of each sync operation
5. Output final statistics

### delete-forks.sh

1. Use GitHub API to fetch all fork repositories in the organization
2. For each fork, resolve its upstream repository for display
3. Display a preview table of all forks and their upstreams
4. Prompt for confirmation (unless `--yes` is used)
5. Delete each fork via `gh repo delete`
6. Output final statistics

## Example Output

### sync-forks.sh

```
=========================================
GitHub Fork Batch Sync for prombot-ai
=========================================

Syncing fork: prombot-ai/project-a
  From parent: original-org/project-a
  ✓ Successfully synced prombot-ai/project-a

Syncing fork: prombot-ai/project-b
  From parent: original-org/project-b
  ✓ Successfully synced prombot-ai/project-b

=========================================
Sync Summary
=========================================
Total forks processed: 2
Successful: 2
Failed: 0
```

### delete-forks.sh

```
=========================================
GitHub Fork Batch Delete for prombot-ai
=========================================

Fetching fork list...

FORK                                     UPSTREAM
---------------------------------------- ----------------------------------------
prombot-ai/project-a                     original-org/project-a
prombot-ai/project-b                     original-org/project-b

Total forks found: 2

Are you sure you want to permanently delete all 2 fork repositories? Type 'yes' to confirm: yes

[1/2] prombot-ai/project-a
  Upstream: original-org/project-a
  ✓ Successfully deleted prombot-ai/project-a

[2/2] prombot-ai/project-b
  Upstream: original-org/project-b
  ✓ Successfully deleted prombot-ai/project-b

=========================================
Delete Summary
=========================================
Total forks processed: 2
Successful: 2
Failed: 0
```

## Important Notes

- Ensure GitHub Token has `repo` and `delete_repo` permissions
- **Always use `--dry-run` first** to preview the effect before making actual changes
- For `sync-forks.sh`: sync operations may overwrite local changes in the fork
- For `delete-forks.sh`: deletion is **permanent and irreversible**; use with caution
- If there are conflicts between fork and upstream, manual resolution may be required

## Troubleshooting

### Common Issues

**1. Token not set**
```
Error: GITHUB_TOKEN environment variable is not set
```
Solution: Set the `GITHUB_TOKEN` environment variable

**2. Not authenticated with GitHub CLI**
```
Error: HTTP 401: Unauthorized
```
Solution: Run `gh auth login` to re-authenticate

**3. Insufficient permissions**
```
Error: Resource not accessible by integration
```
Solution: Ensure the Token has `repo` permission

## License

MIT License
