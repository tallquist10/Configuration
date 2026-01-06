export XDG_CONFIG_HOME=/Users/ctallquist
export PATH=$PATH:/Users/ctallquist/go/bin

alias ls='ls -la'
alias top='top -o mem'
alias szsh='source ~/.zshrc'
alias mkdir='mkdir -p'


function awsctx() {
  if [ -n "$1" ]; then
    if aws configure list-profiles | grep -q "^$1$"; then
      export AWS_PROFILE="$1"
      echo "Switched to profile ""$AWS_PROFILE""."
    else
      echo "Error: Profile '$1' not found in available AWS profiles."
      return 1
    fi
  else
    export AWS_PROFILE="$(aws configure list-profiles | fzf)"
    echo "Switched to profile ""$AWS_PROFILE""."
  fi
}

# amp
export PATH="~/.local/bin:$PATH"

# amp
export PATH="~/.local/bin:$PATH"
