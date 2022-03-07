#
# ~/.bashrc
#


# If not running interactively, don't do anything
[[ $- != *i* ]] && return



#
# NodeJs related section
#
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
NODE_DEFAULT_VERSION=$(<"$NVM_DIR/alias/default")
export PATH=$PATH:"$NVM_DIR/versions/node/$NODE_DEFAULT_VERSION/bin"
export NVIM_COC_LOG_FILE=/tmp/vim-coc-logs.txt



#
# generic bash setup
#
complete -cf sudo
PS1='[\u@\h \W]\$ '
#xset r rate 1000 1 
setxkbmap -option 'numpad:microsoft'
set -o vi
setxkbmap -option caps:swapescape
export EDITOR=vim
source /usr/share/bash-completion/bash_completion



#
# common aliases
#
alias tmux="tmux -u"
alias vim='TERM="" nvim'
alias ls='ls --color=auto'
alias gr="goToGitRoot"
alias k=kubectl



#
# kubernates section
#
source <(kubectl completion bash)
complete -F __start_kubectl k
complete -C /usr/bin/kustomize kustomize



#
# execute path setup
#
export PATH=$PATH:/usr/local/bin:/usr/local/sbin:/usr/bin
export PATH=$PATH:/usr/lib/jvm/default/bin:/usr/bin/site_perl
export PATH=$PATH:/usr/bin/vendor_perl:/usr/bin/core_perl
export PATH=$PATH:/usr/share/dotnet



# fzf(fuzzy search finder) setup
[ -f ~/.fzf.bash ] && source ~/.fzf.bash


#
# go one git repo up
#
function goToGitRoot() {
    is_git_repo="$(git rev-parse --is-inside-work-tree 2>/dev/null)"
    if [ "$is_git_repo" != true ]; then
      echo "not in git repository"
      return
    fi
    git_root="$(git rev-parse --show-toplevel)"
    cur_work_dir="$(pwd)"
    if [ "$git_root" != "$cur_work_dir" ]; then
        cd "$git_root"
        return
    fi
    parent_dir="$(dirname "$(pwd)")"
    cd $parent_dir
    is_parent_dir_git_repo="$(git rev-parse --is-inside-work-tree 2>/dev/null)"
    if [ "$is_parent_dir_git_repo" != true ]; then
        echo "no git repo found in up dirs"
        cd $cur_work_dir
        return
    fi
    parent_dir_git_root="$(git rev-parse --show-toplevel)"
    cd $parent_dir_git_root
} 


# rust programming language setup
. "$HOME/.cargo/env"
