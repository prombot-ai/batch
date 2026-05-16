# GitHub Fork Batch Sync

Batch sync all fork repositories in a GitHub organization.

## Features

- Automatically fetch all fork repositories in an organization
- Batch sync forks with upstream repositories
- Dry Run mode support
- Force sync support
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

## Parameters

| Parameter | Description |
|-----------|-------------|
| `--dry-run` | Preview mode, shows what would be synced without making changes |
| `--force` | Force sync, execute even if fork is already in sync with upstream |
| `--help` | Show help information |

## How It Works

1. Use GitHub API to fetch all fork repositories in the specified organization
2. For each fork, identify its upstream repository (parent repository)
3. Use `gh repo sync` command to sync updates from upstream to the fork
4. Record success/failure status of each sync operation
5. Output final statistics

## Example Output

```
=========================================
GitHub Fork Batch Sync for prombot-ai
=========================================

Fetching fork repositories from organization: prombot-ai
Found 3 fork(s)

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

## Important Notes

- Ensure GitHub Token has `repo` permission to perform sync operations
- Sync operations will overwrite local changes in the fork (if any)
- It's recommended to use `--dry-run` parameter first to preview the effect
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
