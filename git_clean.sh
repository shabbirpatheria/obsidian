#!/usr/bin/env bash
set -e

# -------- CONFIG --------
NEW_BRANCH="temp-clean"
FINAL_BRANCH="main"
COMMIT_MESSAGE="Initial commit"
# ------------------------

# Ensure we are inside a git repo
if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "❌ Not inside a git repository"
  exit 1
fi

CURRENT_BRANCH=$(git branch --show-current)

echo "⚠️  This will DELETE ALL GIT HISTORY and keep ONE commit."
echo "📍 Current branch: $CURRENT_BRANCH"
read -p "Continue? (y/N): " CONFIRM

if [[ "$CONFIRM" != "y" ]]; then
  echo "❌ Aborted"
  exit 0
fi

# Create orphan branch
git checkout --orphan "$NEW_BRANCH"

# Stage everything
git add -A

# Commit
git commit -m "$COMMIT_MESSAGE"

# Delete old branch if it exists
if git show-ref --quiet refs/heads/"$FINAL_BRANCH"; then
  git branch -D "$FINAL_BRANCH"
fi

# Rename orphan branch to main
git branch -m "$FINAL_BRANCH"

# Push if remote exists
if git remote | grep -q origin; then
  echo "🚀 Force pushing to origin/$FINAL_BRANCH"
  git push --force --set-upstream origin "$FINAL_BRANCH"
else
  echo "ℹ️  No remote found, skipping push"
fi

# Cleanup
git gc --aggressive --prune=now

echo "✅ Done! Repository now has a single commit."
