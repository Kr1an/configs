home_dir=$HOME
cur_dir=$(pwd)

# tmux
mv -f $home_dir/.tmux.conf $home_dir/.tmux.conf.DEP 2> /dev/null
ln -s $cur_dir/tmux.conf $home_dir/.tmux.conf

# bashrc
mv -f $home_dir/.bashrc $home_dir/.bashrc.DEP 2> /dev/null
ln -s $cur_dir/bashrc $home_dir/.bashrc

# nvim
nvim_dir=$home_dir/.config/nvim
mv -f $nvim_dir/init.vim $nvim_dir/init.vim.DEP 2> /dev/null
ln -s $cur_dir/vim.vim $nvim_dir/init.vim
mkdir -p $nvim_dir/lua
mv -f $nvim_dir/lua/setup-nvim.lua $nvim_dir/lua/setup-nvim.lua.DEP 2> /dev/null
ln -s $cur_dir/vim.lua $nvim_dir/lua/setup-nvim.lua

# xterm
mv -f $home_dir/.Xresources $home_dir/.Xresources.DEP 2> /dev/null
ln -s $cur_dir/xterm $home_dir/.Xresources
