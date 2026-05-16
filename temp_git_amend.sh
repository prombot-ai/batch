#!/bin/bash
cd /c/Users/lemon/Documents/Trae/github-batch

echo "=== Setting executable permission ==="
chmod +x sync-forks.sh
ls -la sync-forks.sh

echo ""
echo "=== Git Status ==="
git status

echo ""
echo "=== Git Add ==="
git add -A

echo ""
echo "=== Git Commit Amend ==="
git commit -a --amend --no-edit

echo ""
echo "=== Commit amended successfully ==="
