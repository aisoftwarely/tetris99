#!/bin/sh
# 把网页版游戏同步进 iOS 壳的资源目录（云端构建也会执行同样的一步）
set -e
cd "$(dirname "$0")/.."
cp web/index.html Tetris99/Resources/index.html
echo "synced web/index.html -> Tetris99/Resources/index.html"
