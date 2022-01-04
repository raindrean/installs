echo "This is the bootstrap script"

touch ~/.zshrc

source ~/.zshrc

# 如果CONFIG_ROOT_DIR变量不存在，则通过用户输入来设置
if [[ -z $CONFIG_ROOT_DIR ]]; then
	if [ -n "$ZSH_VERSION" ]; then
		read 'config_root?input config root dir: '
	elif [ -n "$BASH_VERSION" ]; then
		read -p 'input config root dir: ' config_root
	else
		echo "not zsh or bash, exit"
		exit 0
	fi
	config_root="${config_root/#\~/$HOME}"
	# 如果输入的文件夹不存在，则询问是否创建
	if [ ! -d "$config_root" ]; then
		if [ -n "$ZSH_VERSION" ]; then
			read 'to_create_folder_or_not?dir not exit, created? y/n: '
		elif [ -n "$BASH_VERSION" ]; then
			read -p 'dir not exit, created? y/n: ' to_create_folder_or_not
		fi
		if [[ $to_create_folder_or_not == "y" ]] || [[ $to_create_folder_or_not == "Y" ]]; then
			mkdir -p "$config_root"
		else
			echo "not create config root dir, exit"
			exit 0
		fi
	fi
	echo "CONFIG_ROOT_DIR=$config_root" >> ~/.zshrc
	CONFIG_ROOT_DIR=$config_root
fi

if [ ! -d "$CONFIG_ROOT_DIR/ztools" ]; then
	git clone git@github.com:raindrean/ztools.git $CONFIG_ROOT_DIR/ztools
else
	CUR=$(pwd)
	cd "$CONFIG_ROOT_DIR/ztools"
	git pull
fi

# TODO: 如果zshrc里面已有这句话，则不写入
echo "source $CONFIG_ROOT_DIR/ztools/init.sh" >> ~/.zshrc

source ~/.zshrc
