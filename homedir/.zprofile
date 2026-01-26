##############################################################################
#Import the shell-agnostic (Bash or Zsh) environment config
##############################################################################
source ~/.profile

##############################################################################
# History Configuration
##############################################################################
HISTSIZE=5000               #How many lines of history to keep in memory
HISTFILE=~/.zsh_history     #Where to save history to disk
SAVEHIST=5000               #Number of history entries to save to disk
HISTDUP=erase               #Erase duplicates in the history file
setopt    appendhistory     #Append history to the history file (no overwriting)
setopt    sharehistory      #Share history across terminals
setopt    incappendhistory  #Immediately append to the history file, not just when a term is killed

# macOS-specific paths and Homebrew setup
if [[ "$OSTYPE" == "darwin"* ]]; then
    # Setting PATH for Python 3.6
    PATH="/Library/Frameworks/Python.framework/Versions/3.6/bin:${PATH}"

    # Setting PATH for Python 3.12
    PATH="/Library/Frameworks/Python.framework/Versions/3.12/bin:${PATH}"
    export PATH

    # Homebrew setup (Apple Silicon vs Intel)
    if [ -f /opt/homebrew/bin/brew ]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
    elif [ -f /usr/local/bin/brew ]; then
        eval "$(/usr/local/bin/brew shellenv)"
    fi
fi
