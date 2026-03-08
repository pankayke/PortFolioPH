# Git Workflow Guide – PortFolioPH

> **Quick reference for committing sprint work with Jira integration**

---

## Quick Start – Committing Sprint Work

### 1. Create Feature Branch

```bash
# From develop branch
git checkout develop
git pull origin develop

# Create feature branch (use Jira key)
git checkout -b feature/PF-27-auth-service
```

### 2. Make Changes and Commit with Jira Reference

```bash
# Stage your changes
git add lib/data/services/auth_service.dart
git add lib/core/exceptions/auth_exception.dart

# Commit with Jira key in message
git commit -m "PF-27: Implement AuthService for user authentication

Created centralized authentication service with register/login methods.
Includes password hashing, email uniqueness check, and session management.

Files added:
- lib/data/services/auth_service.dart (186 lines)
- lib/core/exceptions/auth_exception.dart (32 lines)

Story: STORY-010
Estimated: 4h | Actual: 4h"
```

### 3. Push to Remote

```bash
# Push feature branch
git push origin feature/PF-27-auth-service
```

### 4. Merge to Develop

```bash
# Switch to develop
git checkout develop
git pull origin develop

# Merge feature branch
git merge feature/PF-27-auth-service --no-ff

# Push develop
git push origin develop

# Delete feature branch (optional)
git branch -d feature/PF-27-auth-service
git push origin --delete feature/PF-27-auth-service
```

---

## Commit Message Template

```
PF-<NUMBER>: <type>: <short description>

<detailed description>

Files added/modified:
- path/to/file1.dart (description)
- path/to/file2.dart (description)

Story: STORY-XXX
Estimated: Xh | Actual: Xh
```

### Commit Types
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation
- `refactor`: Code refactoring
- `test`: Tests
- `chore`: Maintenance

---

## Sprint Workflow

### Starting a Sprint

```bash
# Create sprint branch from develop
git checkout develop
git checkout -b sprint/2-authentication

# Work on individual features in feature branches
git checkout -b feature/PF-27-auth-service
```

### During Sprint

For each Jira task:

```bash
# 1. Create feature branch
git checkout develop
git checkout -b feature/PF-XX-task-name

# 2. Implement feature
# ... make changes ...

# 3. Commit with Jira reference
git add .
git commit -m "PF-XX: feat: implement task

Detailed description...

Story: STORY-XXX"

# 4. Push to remote
git push origin feature/PF-XX-task-name

# 5. Merge to develop when ready
git checkout develop
git merge feature/PF-XX-task-name --no-ff
git push origin develop
```

### Ending a Sprint

```bash
# 1. Merge all features to develop
git checkout develop
git pull origin develop

# 2. Create sprint completion commit
git commit -m "PF-XX: Merge Sprint X to develop

Sprint X Summary:
├─ XX new files
├─ XX modified files
├─ XX lines of code added
├─ XX hours actual time
└─ All XX stories complete

Ready for Sprint X+1"

# 3. Merge develop to main for release
git checkout main
git pull origin main
git merge develop --no-ff

# 4. Tag release
git tag -a v1.X.0-sprintX -m "Sprint X - Description"
git push origin main --tags

# 5. Push develop
git checkout develop
git push origin develop
```

---

## Useful Commands

### Viewing History

```bash
# View commit history with graph
git log --oneline --graph --all

# View commits for specific Jira issue
git log --grep="PF-27"

# View files changed in commit
git show <commit-hash> --stat

# View detailed diff
git show <commit-hash>
```

### Working with Branches

```bash
# List all branches
git branch -a

# Delete local branch
git branch -d feature/PF-XX-name

# Delete remote branch
git push origin --delete feature/PF-XX-name

# Rename current branch
git branch -m new-name
```

### Undoing Changes

```bash
# Discard unstaged changes
git restore <file>

# Unstage file
git restore --staged <file>

# Amend last commit
git commit --amend -m "New message"

# Undo last commit (keep changes)
git reset --soft HEAD~1

# Undo last commit (discard changes)
git reset --hard HEAD~1
```

---

## Check Each Sprint's Files

Use this script to see all files modified per sprint:

```bash
# Sprint 1 files
git log --name-only --pretty=format: --grep="PF-9\|PF-10\|PF-11\|PF-12\|PF-13\|PF-14\|PF-15\|PF-16\|PF-17\|PF-18\|PF-19\|PF-20\|PF-21\|PF-22\|PF-23\|PF-24\|PF-25\|PF-26" | sort -u

# Sprint 2 files
git log --name-only --pretty=format: --grep="PF-27\|PF-28\|PF-29\|PF-30\|PF-31\|PF-32\|PF-33\|PF-34\|PF-35\|PF-36\|PF-37\|PF-38\|PF-39\|PF-40\|PF-41\|PF-42\|PF-43\|PF-44" | sort -u
```

---

## Jira Integration

### How GitHub-Jira Connection Works

1. **Commit Reference**: Use `PF-XX` at start of commit message
2. **Auto-link**: Jira shows commits in Development panel
3. **Status Update**: Commits appear in issue activity feed
4. **Branch Link**: Feature branches linked if named `feature/PF-XX-*`
5. **PR Link**: Pull requests show in Jira if title has `PF-XX`

### Example Flow

```bash
# 1. Branch name includes Jira key
git checkout -b feature/PF-27-auth-service

# 2. Commit message starts with key
git commit -m "PF-27: Implement AuthService"

# 3. Push (triggers Jira webhook)
git push origin feature/PF-27-auth-service

# 4. Create PR with Jira key in title
# PR Title: "PF-27: Add AuthService implementation"

# Result: Jira PF-27 shows:
# - Branch: feature/PF-27-auth-service
# - Commits: 3 commits
# - PR: #123 Open
```

---

## Bulk Commit Template

For committing multiple sprint files at once:

```bash
# Sprint 1 bulk commit
git add lib/core/ lib/data/ lib/presentation/ pubspec.yaml README.md
git commit -m "PF-25: Complete Sprint 1 - Core Setup & Architecture

Implemented full clean architecture foundation with:
- 10-table SQLite database
- 8 repository classes
- 4 state providers
- GoRouter with auth guard
- Material 3 theme system
- Splash and navigation scaffold

Total: 47 files, ~6,800 lines of code

Sprint 1 Stories:
- PF-9: Project initialization ✅
- PF-10: Architecture scaffold ✅
- PF-11: Database implementation ✅
- PF-12: Data models ✅
- PF-13: Repositories ✅
- PF-14: Constants & utilities ✅
- PF-15: Theme system ✅
- PF-16: Routing ✅
- PF-17: Providers ✅
- PF-18: Splash screen ✅
- PF-19: Navigation scaffold ✅
- PF-20: Main app wiring ✅

Estimated: 32h | Actual: 32h"

git push origin develop
```

---

## Checking Out PortfolioFR Reference

Though the reference repo is empty, here's how to add it as a remote for future reference:

```bash
# Add as remote
git remote add portfoliofr https://github.com/auzcee/PortfolioFR.git

# Fetch branches
git fetch portfoliofr

# View remote branches
git branch -r

# Compare structures (when populated)
git diff develop portfoliofr/main --name-status
```

---

## Best Practices

### Commit Frequency
- ✅ **DO**: Commit after each completed task/subtask
- ✅ **DO**: Use descriptive, specific messages
- ✅ **DO**: Reference Jira keys in every commit
- ❌ **DON'T**: Commit unfinished/broken code to develop
- ❌ **DON'T**: Use generic messages like "fixes" or "updates"

### Branch Naming
- ✅ `feature/PF-27-auth-service`
- ✅ `bugfix/PF-102-login-crash`
- ✅ `hotfix/PF-150-critical-security`
- ❌ `temp`, `test`, `wip`, `my-branch`

### Merge Strategy
- ✅ Use `--no-ff` to preserve feature branch history
- ✅ Squash commits if feature has many tiny commits
- ✅ Write detailed merge commit messages
- ❌ Don't force push to develop or main

---

## Troubleshooting

### "Detached HEAD state"
```bash
# Create branch from current state
git checkout -b feature/recovery

# Or restore to last commit
git checkout develop
```

### "Merge conflict"
```bash
# 1. View conflicting files
git status

# 2. Edit files, resolve conflicts
# Look for <<<<<<< HEAD markers

# 3. Stage resolved files
git add <resolved-files>

# 4. Complete merge
git commit -m "Resolved merge conflicts in X"
```

### "Push rejected"
```bash
# Someone pushed before you
git pull --rebase origin develop

# Resolve any conflicts, then
git push origin develop
```

---

**Last Updated:** March 9, 2026  
**Maintained by:** Mark Leannie Gacutno
