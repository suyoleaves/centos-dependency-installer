#!/bin/bash

# 参数解析
while [ "$1" != "" ]; do
    case $1 in
        -f | --file ) shift; DEPS_FILE=$1 ;;
        * ) echo "用法: $0 -f <依赖文件>"; exit 1 ;;
    esac
    shift
done

if [ -z "$DEPS_FILE" ] || [ ! -f "$DEPS_FILE" ]; then
    echo "错误：请指定有效依赖文件（-f 参数）"
    exit 1
fi

# 读取依赖项（过滤注释和空行）
dependencies=()
while IFS= read -r line; do
    line=$(echo "$line" | sed 's/#.*//' | xargs) # 去除注释和空格
    [ -n "$line" ] && dependencies+=("$line")
done < "$DEPS_FILE"

# 检查必要工具
required_tools=("yumdownloader" "createrepo")
for tool in "${required_tools[@]}"; do
    if ! command -v "$tool" &> /dev/null; then
        echo "请先安装 yum-utils 包：sudo yum install yum-utils"
        exit 1
    fi
done

# 创建临时目录
TMP_DIR=$(mktemp -d)
trap 'rm -rf "$TMP_DIR"' EXIT

# 下载依赖 RPM 包
echo "正在下载依赖项..."
for dep in "${dependencies[@]}"; do
    echo "处理依赖: $dep"
    sudo yumdownloader --resolve --destdir="$TMP_DIR" "$dep" || {
        echo "警告：$dep 下载失败"
    }
done

# 生成仓库元数据
echo "生成仓库元数据..."
createrepo "$TMP_DIR"

# 打包为 tar.gz
OUTPUT_FILE="agent_yum_repo_$(date +%Y%m%d%H%M%S).tar.gz"
tar -czf "$OUTPUT_FILE" -C "$TMP_DIR" .
echo "离线包已生成：$(pwd)/$OUTPUT_FILE"
