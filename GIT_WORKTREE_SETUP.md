# Dotfiles Enhancement Summary

This document describes all the enhancements made to the dotfiles configuration, including git worktree support and other improvements.

## Overview

We've implemented a comprehensive git worktree workflow that integrates:
- **Neovim** with telescope-based worktree management
- **tmux** with worktree-aware session naming
- **Shell functions** for quick worktree operations
- **Bare repository** support for organized worktree structures

## Changes Made

### 1. Neovim Configuration

#### Added Plugins (`homedir/nvim/lua/impulse/lazy/git.lua`)
- **git-worktree.nvim** (polarmutex fork v2) - Modern git worktree management
- **persisted.nvim** - Branch-aware session management
- **toggleterm.nvim** - Replaced floaterm, includes lazygit integration
- **oil.nvim** - Modern file explorer

#### Key Mappings
- `<leader>gw` - List and switch between git worktrees (via Telescope)
- `<leader>gW` - Create new git worktree with branch name and base branch prompts
- `<leader>gl` - Open lazygit in a floating terminal
- `<leader>o` - Open oil file explorer

#### LSP Enhancement (`homedir/nvim/lua/impulse/lazy/lsp.lua`)
- Added worktree-aware LSP workspace folder detection
- Automatically adds worktree root as LSP workspace folder

#### Harpoon Configuration (`homedir/nvim/lua/impulse/lazy/harpoon.lua`)
- Enabled `mark_branch = true` for branch-specific file marks

### 2. tmux-sessionizer Script (`scripts/tmux-sessionizer`)

#### Enhanced Features
- **Worktree Discovery**: Automatically finds git worktrees in all project directories
- **Bare Repository Support**: Properly handles worktrees inside bare repositories
- **Smart Session Naming**:
  - Regular repos: `project-name`
  - Worktrees in bare repos: `project-name-branch-name`
  - Regular repos on non-default branches: `project-name-branch-name`
- **FZF Preview**: Shows git status, branch info, and recent commits
- **Worktree Creation**: `tmux-sessionizer new-worktree branch-name`

#### Session Name Examples
```
rf-api                    # Bare repository
rf-api-main              # Main worktree
rf-api-accounts-refactor # Feature branch worktree
```

### 3. Shell Functions (`homedir/.shellfn`)

#### New Functions Added
```bash
# Smart worktree creation with tmux integration
gwt-smart branch-name [base-branch]
# Creates worktree and automatically switches tmux session

# Worktree switching with fzf
gwt-switch
# Interactive worktree switcher using fzf

# Clean up merged worktrees
gwt-cleanup
# Removes worktrees whose branches are merged into main
```

### 4. Git Configuration

#### Existing Worktree Aliases (already in your setup)
- `gwt` - git worktree
- `gwta` - git worktree add
- `gwtls` - git worktree list
- `gwtmv` - git worktree move
- `gwtrm` - git worktree remove

## Workflow Examples

### Creating a New Feature Branch
```bash
# Method 1: From Neovim
<leader>gW
> New worktree branch name: feature-awesome
> Base branch: [Enter for main]

# Method 2: From shell
gwt-smart feature-awesome develop

# Method 3: Using tmux-sessionizer
tmux-sessionizer new-worktree feature-awesome
```

### Switching Between Worktrees
```bash
# Method 1: From Neovim
<leader>gw  # Opens telescope picker

# Method 2: From tmux
Ctrl+Space F  # Opens fzf with all projects/worktrees

# Method 3: From shell
gwt-switch  # Interactive switcher
```

### Bare Repository Structure
```
~/projects/php/rf-api/              # Bare repository
├── objects/                        # Git objects
├── refs/                          # Git refs
├── main/                          # Main branch worktree
├── develop/                       # Develop branch worktree
└── feature-xyz/                   # Feature branch worktree
```

## Quick Reference

### Neovim Commands
| Key | Action |
|-----|--------|
| `<leader>gw` | List/switch worktrees |
| `<leader>gW` | Create new worktree |
| `<leader>gl` | Open lazygit |
| `<leader>o` | File explorer (oil) |

### tmux Commands
| Key | Action |
|-----|--------|
| `Ctrl+Space F` | Fuzzy find projects/worktrees |
| `Ctrl+Space D` | Jump to dotfiles |
| `Ctrl+Space K` | Jump to kate project |
| `Ctrl+Space A` | Jump to rf-api project |

### Shell Commands
| Command | Action |
|---------|--------|
| `gwt-smart branch [base]` | Create worktree with tmux session |
| `gwt-switch` | Interactive worktree switcher |
| `gwt-cleanup` | Remove merged worktrees |
| `gwtls` | List all worktrees |
| `gwtrm worktree` | Remove specific worktree |

## Tips

1. **Bare Repository Setup**: For cleaner organization, convert existing repos to bare:
   ```bash
   git clone --bare https://github.com/user/repo.git
   cd repo.git
   git worktree add main main
   ```

2. **Session Persistence**: Neovim sessions are automatically saved per-branch with persisted.nvim

3. **Quick Context Switching**: Combine Harpoon marks with worktrees for ultra-fast file navigation

4. **Cleanup Routine**: Run `gwt-cleanup` periodically to remove merged feature branches

## Other Non-Worktree Changes

### 1. Neovim Plugin Updates (`homedir/nvim/lua/impulse/lazy/init.lua`)

#### Replaced Plugins
- **floaterm → toggleterm.nvim**: Better terminal integration with floating support
  - `<F1>` - Toggle floating terminal
  - `<leader>gl` - Open lazygit in floating terminal

#### Added Plugins
- **oil.nvim**: Modern file explorer as a buffer
  - `<leader>o` - Open oil file explorer
- **vim-surround**: Added for surrounding text manipulation

### 2. AI/LLM Configuration (`homedir/nvim/lua/impulse/lazy/avante.lua`)
- Updated Claude model to `claude-sonnet-4-20250514`
- Commented out alternative LLM providers (Groq, OpenAI configurations remain for easy switching)

### 3. Environment and Security

#### Shell Variables (`homedir/.shellvars`)
- **Security Note**: Contains API keys that should be moved to secure storage
- Removed sensitive API keys from version control

#### Zsh Configuration (`homedir/.zshrc`)
- Added automatic `.env` file sourcing for project-specific environment variables:
  ```bash
  if [[ -f "$HOME/projects/dotfiles/.env" ]]; then
      set -a
      source "$HOME/projects/dotfiles/.env"
      set +a
  fi
  ```

### 4. Documentation
- Created `CLAUDE.md` - Guidance for future Claude Code instances working with this repository
- Created this comprehensive setup guide

## Configuration Files Modified

1. `homedir/nvim/lua/impulse/lazy/git.lua` - Git plugins and worktree setup
2. `homedir/nvim/lua/impulse/lazy/init.lua` - Added oil.nvim, toggleterm, vim-surround
3. `homedir/nvim/lua/impulse/lazy/lsp.lua` - Worktree-aware LSP
4. `homedir/nvim/lua/impulse/lazy/harpoon.lua` - Branch-specific marks
5. `homedir/nvim/lua/impulse/lazy/avante.lua` - Updated AI model configuration
6. `scripts/tmux-sessionizer` - Complete rewrite for worktree support
7. `homedir/.shellfn` - Added gwt-* helper functions
8. `homedir/.shellvars` - Security improvements (removed API keys)
9. `homedir/.zshrc` - Added .env file sourcing
10. `CLAUDE.md` - Repository documentation for AI assistants
11. `GIT_WORKTREE_SETUP.md` - This comprehensive guide