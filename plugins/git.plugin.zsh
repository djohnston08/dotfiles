function push_remote
{
    git push $1 HEAD
}

function delete_remote_tag
{
    argc=$#
    case $argc in
        1)
            tag="$1"
            git ls-remote | grep "refs/tags/${tag}$" >/dev/null 2>&1
            if (( $? == 0 )); then
                git push origin :refs/tags/${tag}
            else
                echo "No tag named $tag exists on origin"
            fi
            ;;
        2)
            tag="$1"
            remote="$2"
            git ls-remote $remote | grep "refs/tags/${tag}$" >/dev/null 2>&1
            if (( $? == 0 )); then
                git push $remote :refs/tags/${tag}
            else
                echo "No tag named $tag exists on $remote"
            fi
            ;;
        *)
            echo "Usage: $0 <tag> [<remote>]"
            ;;
    esac
}

function show_commits
{
    if (( $# > 1 )); then
        echo "Usage: show_commits [commit]"
        echo "commit: defaults to HEAD"
        return
    fi
    commit="$1"
    if [[ "X$commit" == "X" ]]; then
        commit="HEAD"
    fi

    git show $commit
}

# Aliases
alias g='git'
compdef g=git
alias gst='git status'
compdef _git gst=git-status
alias gp='git pull --prune'
compdef _git gp=git-pull
alias gf='git fetch --prune'
compdef _git gf=git-fetch
alias gpr='git pull --rebase'
compdef _git gpr=git-pull
alias gup='git fetch && git rebase'
compdef _git gup=git-fetch
alias gpush='git push'
compdef _git gpush=git-push
gdv() { git diff -w "$@" | view - }
compdef _git gdv=git-diff
alias gc='git commit -v'
compdef _git gc=git-commit
alias gca='git commit -v -a'
compdef _git gca=git-commit
alias gco='git checkout'
compdef _git gco=git-checkout
alias gcm='git checkout master'
alias gb='git branch'
compdef _git gb=git-branch
alias gba='git branch -a'
compdef _git gba=git-branch
alias gbr='git branch -r'
compdef _git gbr=git-branch
alias gbd='git branch -d'
compdef _git gbd=git-branch
alias gbD='git branch -D'
compdef _git gbD=git-branch
alias gcount='git shortlog -sn'
compdef gcount=git
alias gcp='git cherry-pick'
compdef _git gcp=git-cherry-pick
alias gl="git log --graph --pretty=format:'%Cred%h%Creset %an: %s - %Creset %C(yellow)%d%Creset %Cgreen(%cr)%Creset' --abbrev-commit --date=relative"
compdef _git gl=git-log
alias glp='git log -p'
compdef _git glp=git-log
alias gln='git log --name-status'
compdef _git gln=git-log
alias glol='git log --graph --decorate --pretty=oneline --abbrev-commit'
compdef _git glol=git-log
alias glola='git log --graph --decorate --pretty=oneline --abbrev-commit --all'
compdef _git glola=git-log
alias glg='git log --stat --max-count=5'
compdef _git glg=git-log
alias glgg='git log --graph --max-count=5'
compdef _git glgg=git-log
alias gs='git status -sb'
compdef _git gss=git-status
alias ga='git add'
compdef _git ga=git-add
alias gaa='git add -A'
compdef _git ga=git-add
alias gm='git merge'
compdef _git gm=git-merge
alias grh='git reset HEAD'
alias grhh='git reset HEAD --hard'
alias gd='git diff'
compdef _git gd=git-diff
alias gdel="git status | grep deleted | awk '{print \$3}' | xargs git rm"
alias gt='git tag -l'
compdef _git gt=git-tag
alias gtd='git tag -d'
compdef _git gtd=git-tag
alias gtdr='delete_remote_tag'
alias gsa='git stash apply'
compdef _git gsa=git-stash
alias gsc='git stash clear'
compdef _git gsc=git-stash
alias gsl='git stash list'
compdef _git gsl=git-stash
alias gss='git stash save'
compdef _git gss=git-stash
alias gr='git rebase'
compdef _git gr=git-rebase
alias gri='git rebase -i'
compdef _git gri=git-rebase
alias grm='git rebase master'
alias gsh='show_commits'
compdef _git gsh=git-show

# Git and svn mix
alias git-svn-dcommit-push='git svn dcommit && git push github master:svntrunk'
compdef git-svn-dcommit-push=git

alias gsr='git svn rebase'
alias gspull='git svn fetch && git svn rebase'
alias gspush='git svn dcommit'
#
# Will return the current branch name
# Usage example: git pull origin $(current_branch)
#
function current_branch() {
  ref=$(git symbolic-ref HEAD 2> /dev/null) || return
  echo ${ref#refs/heads/}
}

# these aliases take advantage of the previous function
alias ggpull='git pull origin $(current_branch)'
compdef ggpull=git
alias ggpush='git push origin $(current_branch)'
compdef ggpush=git
alias ggpnp='git pull origin $(current_branch) && git push origin $(current_branch)'
compdef ggpnp=git

## FROM BASHRC TO BE CONVERTED
# git aliases
# function push_remote
# {
#     git push $1 HEAD
# }
# 
# function delete_remote_tag
# {
#     argc=$#
#     case $argc in
#         1)
#             tag="$1"
#             git ls-remote | grep "refs/tags/${tag}$" >/dev/null 2>&1
#             if (( $? == 0 )); then
#                 git push origin :refs/tags/${tag}
#             else
#                 echo "No tag named $tag exists on origin"
#             fi
#             ;;
#         2)
#             tag="$1"
#             remote="$2"
#             git ls-remote $remote | grep "refs/tags/${tag}$" >/dev/null 2>&1
#             if (( $? == 0 )); then
#                 git push $remote :refs/tags/${tag}
#             else
#                 echo "No tag named $tag exists on $remote"
#             fi
#             ;;
#         *)
#             echo "Usage: $0 <tag> [<remote>]"
#             ;;
#     esac
# }
# 
# alias ga='git add'
# alias gaa='git add -A'
# alias gb='git branch'
# alias gba='git branch -a'
# alias gbr='git branch -r'
# alias gbd='git branch -d'
# alias gbD='git branch -D'
# alias gc='git commit'
# alias gca='git commit -a'
# alias gclean='git clean -f -d -x'
# alias gco='git checkout'
# alias gd='git diff'
# alias gdel="git status | grep deleted | awk '{print \$3}' | xargs git rm"
# alias gf='git flow'
# alias gfetch='git fetch'
# alias gff='git flow feature'
# alias gfh='git flow hotfix'
# alias gfr='git flow release'
# alias ghr='git reset --hard'
# alias gl="git log --graph --pretty=format:'%Cred%h%Creset %an: %s - %Creset %C(yellow)%d%Creset %Cgreen(%cr)%Creset' --abbrev-commit --date=relative"
# alias glp='git log -p'
# alias gln='git log --name-status'
# alias glol='git log --graph --decorate --pretty=oneline --abbrev-commit'
# alias glola='git log --graph --decorate --pretty=oneline --abbrev-commit --all'
# alias gls='git ls-file'
# alias gm='git merge'
# alias gmv='git mv'
# alias gnb='git checkout -b'
# alias gp='git pull --prune'
# alias gpr='git pull --rebase --prune'
# alias gpush='git push origin HEAD'
# alias gpushx='push_remote'
# alias gr='git rebase'
# alias gri='git rebase -i'
# alias grm='git rebase master'
# alias gs='git status -sb'
# alias gsa='git stash apply'
# alias gsc='git stash clear'
# alias gsl='git stash list'
# alias gss='git stash save'
# alias gsr='git reset'
# alias gt='git tag -l'
# alias gtd='git tag -d'
# alias gtdr='delete_remote_tag'

