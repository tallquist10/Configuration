alias gc='git commit -S -m'
alias gs='git status'
alias gm='git cm'
alias grm='git rebase -i main'

function osclone() {
  git clone "git@github.com:${1}/${2}" "/Users/ctallquist/src/${1}/${2}"
}

function gitctx() {
  export $GIT_BRANCH="$(git branch | fzf)"
  echo "Switching to ""$GIT_BRANCH""."
  git co $GIT_BRANCH 
} 
