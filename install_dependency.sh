#!/bin/bash

export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

while [ "$1" != "" ]; do
    case $1 in
        -f | --file ) shift; YUM_REPO_TAR=$1 ;;
        * ) echo "用法: $0 -f <离线包路径>"; exit 1 ;;
    esac
    shift
done

if [ -z "$YUM_REPO_TAR" ] || [ ! -f "$YUM_REPO_TAR" ]; then
    echo "错误：请指定有效离线包（-f 参数）"
    exit 1
fi

script_dir=$(dirname "$0")
current_dir=$(pwd)

# 处理 SIGINT 信号
handle_sigint() {
    echo -e "\n检测到SIGINT，脚本将退出。"
    exit 1
}
trap handle_sigint SIGINT

# 备份原始yum源
sudo mkdir -p /etc/yum.repos.d/backup
sudo mv /etc/yum.repos.d/*.repo /etc/yum.repos.d/backup/

# 解压传入的离线包到当前目录
tar -xzf "$YUM_REPO_TAR" -C "$script_dir"

# 设置本地仓库路径
current_dir=$(pwd)
sudo tee /etc/yum.repos.d/local.repo <<EOF
[local]
name=Local Repository
baseurl=file://${current_dir}/offline_yum_repo
enabled=1
gpgcheck=0
EOF

sudo yum clean all
sudo yum makecache
cd offline_yum_repo

# 复制 repodata 目录
sudo cp -r repodata /etc/yum.repos.d/

# 清理并重新生成yum缓存
sudo yum clean all
sudo yum makecache

dependencies=$(cat dependencies.txt)
failed_dependencies=()
for dep in $dependencies; do
    sudo yum --disablerepo=\* --enablerepo=local install -y "$dep"
    if [[ $? -ne 0 ]]; then
        echo "未能安装 $dep，请手动检查并安装。"
        failed_dependencies+=("$dep")
    fi
done

# 还原原始yum源
sudo rm /etc/yum.repos.d/local.repo
sudo mv /etc/yum.repos.d/backup/*.repo /etc/yum.repos.d/
sudo rmdir /etc/yum.repos.d/backup

echo "yum源已还原"

