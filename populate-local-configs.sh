home_dir=$HOME
cur_dir=pwd

mv -f $home_dir/.tmux.conf $home_dir/.tmux.conf.DEP
ln -s $cur_dir/tmux.conf $home_dir/.tmux.conf

mv -f $home_dir/.bashrc $home_dir/.bashrc.DEP
ln -s $cur_dir/bashrc $home_dir/.bashrc

mv -f $home_dir/.vimrc $home_dir/.vimrc.DEP
ln -s $cur_dir/vimrc $home_dir/.config/nvim/init.vim

mv -f $home_dir/.config/nvim/coc-settings $home_dir/.config/nvim/coc-settings.json.DEP
ln -s $cur_dir/coc-settings.json $home_dir/.config/nvim/coc-settings.json

mv -f $home_dir/.Xresources $home_dir/.Xresources.DEP
ln -s $cur_dir/xterm $home_dir/.Xresources
