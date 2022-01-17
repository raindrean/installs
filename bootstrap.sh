echo "This is the bootstrap script"

if [ ! -n "$ZSH_VERSION" ] && [ ! -n "$BASH_VERSION" ]; then
	echo "not zsh or bash, exit"
	exit 0
fi

SHELL_PROFILE=$HOME/.zshrc
SHELL_VAR_FILE=$HOME/.local/SHELL_VARS.sh

if [ -n "$BASH_VERSION" ]; then
	SHELL_PROFILE=$HOME/.bash_profile
fi
touch $SHELL_PROFILE

if [ ! -d ~/.local ]; then
	mkdir -p ~/.local
fi

willCopySHELL_VARS_template=
if [[ ! -f $SHELL_VAR_FILE ]]; then
	willCopySHELL_VARS_template=1
fi

touch $SHELL_VAR_FILE
source $SHELL_VAR_FILE

if [[ -z $CONST_EDITOR ]]; then
	if [ -n "$ZSH_VERSION" ]; then
		read 'const_editor?input const editor: '
	else
		read -p 'input const editor: ' const_editor
	fi
	echo "CONST_EDITOR=$const_editor" >> $SHELL_VAR_FILE
	CONST_EDITOR="$const_editor"
fi

# 如果CONFIG_ROOT_DIR变量不存在，则通过用户输入来设置
if [[ -z $CONFIG_ROOT_DIR ]]; then
	if [ -n "$ZSH_VERSION" ]; then
		read 'config_root?input config root dir: '
	else
		read -p 'input config root dir: ' config_root
	fi
	config_root="${config_root/#\~/$HOME}"
	# 如果输入的文件夹不存在，则询问是否创建
	if [ ! -d "$config_root" ]; then
		if [ -n "$ZSH_VERSION" ]; then
			read 'to_create_folder_or_not?dir not exit, created? y/n: '
		else
			read -p 'dir not exit, created? y/n: ' to_create_folder_or_not
		fi
		if [[ $to_create_folder_or_not == "y" ]] || [[ $to_create_folder_or_not == "Y" ]]; then
			mkdir -p "$config_root"
		else
			echo "not create config root dir, exit"
			exit 0
		fi
	fi
	echo "CONFIG_ROOT_DIR=$config_root" >> $SHELL_VAR_FILE
	CONFIG_ROOT_DIR=$config_root
fi

repoURL=git@github.com:raindrean/ztools.git
if [ ! -d "$CONFIG_ROOT_DIR/ztools" ]; then
	git clone $repoURL $CONFIG_ROOT_DIR/ztools
else
	CUR=$(pwd)
	cd "$CONFIG_ROOT_DIR/ztools"
	git pull
	if [[ $? != 0 ]]; then
		git status
		echo "local repo has conflicts, aborted the bootstrapping..."
		exit 0
	fi
	latest_remote_commit=$(git ls-remote $repoURL HEAD)
	if [[ $? != 0 ]]; then
		echo "getting remote latest HEAD commid id failed... exit"
		exit 0
	fi
	latest_remote_commitId=$(echo "$latest_remote_commit" | cut -d$'\t' -f1)
	if [[ $? != 0 ]]; then
		echo "parsing remote latest HEAD commid id failed... exit"
		exit 0
	fi
	latest_local_commitId=$(git log --format="%H" -n 1)
	if [[ $? != 0 ]]; then
		echo "getting local latest commid id failed... exit"
		exit 0
	fi
	if [[ $latest_remote_commitId != $latest_local_commitId ]]; then
		echo "the remote commid id and local commit id are not the same"
		echo "Please check local repo: $CONFIG_ROOT_DIR/ztools"
		echo "and remote repo: https://github.com/raindrean/ztools or via ssh: $repoURL"
		exit 0
	fi

	# copy variable names to
	if [[ $willCopySHELL_VARS_template == "1" ]]; then
    echo "CONFIG_ROOT_DIR=$config_root" >> $SHELL_VAR_FILE
    cat SHELL_VARS_template.sh >>$SHELL_VAR_FILE
    echo "" >> $SHELL_VAR_FILE
  fi
fi
# TODO: 如果zshrc里面已有这句话，则不写入
echo "source $SHELL_VAR_FILE" >> $SHELL_PROFILE
echo "source $CONFIG_ROOT_DIR/ztools/init.sh" >> $SHELL_PROFILE
