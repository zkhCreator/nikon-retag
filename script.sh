#!/bin/bash

# 检查是否安装了 tag 工具
if ! command -v tag &> /dev/null; then
  echo "tag 工具未安装。请使用以下命令安装："
  echo "brew install tag"
  exit 1
fi

# 定义要处理的目录
DIR=$1

# 检查目录是否存在
if [ ! -d "$DIR" ]; then
  echo "目录不存在: $DIR"
  exit 1
fi

# 遍历所有 JPG 文件
for jpg_file in "$DIR"/*.JPG; do
  # 检查文件是否存在
  if [ ! -f "$jpg_file" ]; then
    continue
  fi

  # 获取文件名（不包括扩展名）
  filename=$(basename -- "$jpg_file")
  filename="${filename%.*}"

  # 获取 JPG 文件的标签，只提取标签部分
  tags=$(tag -Nl "$jpg_file" | tr ',' ' ')

  # 打印调试信息
  echo "checking $jpg_file, tags: $tags"

  # 如果 JPG 文件有标签，则处理
  if [ -n "$tags" ]; then
    # 检查对应的 NEF 文件是否存在
    nef_file="$DIR/$filename.NEF"
    if [ -f "$nef_file" ]; then
      # 给 NEF 文件添加标签
      tag --add "$tags" "$nef_file"
      echo "添加标签到 $nef_file: $tags"

      # 删除 JPG 文件的标签
      tag --remove "$tags" "$jpg_file"
      echo "删除标签从 $jpg_file: $tags"
    else
      echo "找不到 NEF 文件: $nef_file"
    fi
  fi
done
