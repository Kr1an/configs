#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

PS1='[\u@\h \W]\$ '


export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion


#
# go one root up
# - git root
# - npm root
#
function goToRoot() {
    next_root="$(
        prev_loc="$(pwd)";
        while [ 1 ];
        do
            cd ..;
            cur_loc="$(pwd)";
            if [ "$prev_loc" == "$cur_loc" ];
            then
                break;
            fi;
            if [ -d ".git" ] ||
                [ -f "package.json" ] ||
                [ -f *.sln ] ||
                [ -f *.csproj ];
            then
                echo $cur_loc;
                break;
            fi;
            prev_loc="$cur_loc";
        done;
    )"
    if [ "$next_root" != "" ];
    then
        cd $next_root;
    else
        cd ..;
        #echo "next root not found"
    fi;
}

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


###########
# ALIASES #
###########

alias tmux="tmux -u -2"
alias ls='ls --color=auto'
alias gr="goToRoot"
alias k=kubectl
alias tf=terraform
alias g=git
alias n=pnpm
alias vim='IN_VIM=true nvim'
alias file='xdg-open'

# pnpm commands
alias nt="n test"
alias nd="n dev"
alias nb="n build"
alias nl="n live"
alias ns="n start"
alias ni="n install"
alias nl="n list"
alias nr="n remove"

alias sb="n dev:prep && n dev:build"

# yarn commands
alias y="yarn"
alias yb="y build"
alias ys="y start"
alias ydb="y debug"
alias yd="y dev"


# git commands
alias gs="g status"
alias ga="g add"
alias gc="g commit"
alias gd="g diff"
alias gf="g fetch"
alias gm="g merge"
alias gck="g checkout"
alias gl="g log"
alias gsm="g submodule"
alias gb="g branch"
alias gp="g push"
alias gc="g clone"
alias gst="g stash"

alias ll="ls"

alias py="~/python_venv/bin/python"
alias pi="~/python_venv/bin/pip"
alias pylsp="~/python_venv/bin/pylsp"

# rm related commands
alias tt="gio trash"
alias rmforce="/usr/bin/rm"

alias kc="aws eks --region us-east-1 update-kubeconfig --name k8s-cluster-solar"

### other options
complete -cf sudo
source /usr/share/bash-completion/bash_completion
set -o vi
export EDITOR=vim


export PATH=$PATH:~/.local/bin
export PATH=$PATH:/usr/local/Wolfram/WolframEngine/13.1/Executables/
#export PATH=$PATH:~/packages/node/node-20.8.1/install/bin
export PATH=$PATH:~/packages/dotnet/dotnet-sdk-8.0.101-linux-x64
export DOTNET_ROOT=~/packages/dotnet/dotnet-sdk-8.0.101-linux-x64


# execute on each file found by `find`(remove)
# find . -name ".*.sw*" -exec rm {} \;


nvm use v19.6.0

# pnpm
export PNPM_HOME="/home/anton/.local/share/pnpm"
export PATH="$PNPM_HOME:$PATH"
# pnpm end


## ssh into a k8s pod
# kubectl exec -it <Pod_Name> -c <Container_Name> -- /bin/bash
# kubectl exec -it ubuntu -c ubuntu -- /bin/bash
## login to cluster
#aws eks --region example_region update-kubeconfig --name cluster_name
#aws eks --region us-east-1 update-kubeconfig --name k8s-cluster-solar
#kubectl port-forward <pod-name> <local-port>:<pod-port>
#kubectl port-forward <pod-name> 28015:27017
#aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin aws_account_id.dkr.ecr.region.amazonaws.com

## run ts-node with debugger
## nodemon --exec "node --inspect --require ts-node/register download-all-annual-reports.ts"
## node --inspect -r ts-node/register/transpile-only index.ts


# install all language servers:
# ni -g vscode-json-languageserver typescript-language-server


### swap escape and caps
setxkbmap -option caps:swapescape

[ -f ~/.fzf.bash ] && source ~/.fzf.bash
