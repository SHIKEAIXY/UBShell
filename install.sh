#!/bin/bash
architecture=$(uname -m)
if [ "$architecture" == "x86_64" ]; then
echo "当前架构为AMD"
else
echo "当前架构为ARM"
fi

distro=$(lsb_release -si)
version=$(lsb_release -sr)
major_version=$(echo $version | cut -d. -f1)
minor_version=$(echo $version | cut -d. -f2)
    
# 判断是否为Ubuntu系统且主版本号大于等于20
if [ "$distro" = "Ubuntu" ] && [ $major_version -ge 20 ]; then
echo "当前Ubuntu版本为：$version "
else
echo '当前非 Ubuntu，请更换Ubuntu发行版再试'
exit 0
fi

echo "请选择是否更新apt列表和安装必要依赖包"
echo "初次安装使用请yes (yes或no)"

while true; do
read user_input
if [ "$user_input" == "yes" ] || [ "$user_input" == "y" ]; then
echo "正在更新apt列表和升级已安装的软件包"
sudo apt update -y
sudo apt upgrade -y
# 安装必要的包，不可跳过
echo "正在安装必要依赖包中..."
sudo apt install -y apt-transport-https curl ca-certificates software-properties-common
echo "更新成功"
break
elif [ "$user_input" == "no" ] || [ "$user_input" == "n" ]; then
break
else
echo "输入错误，请输入yes或no:"
fi
done

# 检查ffmpeg是否已经安装
if command -v ffmpeg >/dev/null 2>&1; then
echo "ffmpeg已经安装，跳过安装步骤"
else
echo "ffmpeg未安装，开始进行安装"
sudo apt install -y ffmpeg
echo "ffmpeg安装完成"
fi

# 检查nodejs是否已经安装
if [ -z "$(command -v node)" ]; then
echo "nodejs未安装，开始安装..."
# 安装nodejs
sudo apt remove -y libnode-dev
curl -sL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt install -y nodejs
else
echo "nodejs已安装，检查版本..."
# 获取nodejs的版本信息
NODE_VERSION=$(node -v | grep -oE "[0-9]+\.[0-9]+\.[0-9]+")
IFS='.' read -r major minor patch <<< "$NODE_VERSION"
major=$((10#$major))
minor=$((10#$minor))
patch=$((10#$patch))

# 判断版本是否大于或等于20
if [[ $major -lt 20 ]]; then
echo "nodejs版本小于20，重新安装nodejs20中..."
# 安装nodejs
sudo apt remove -y libnode-dev
curl -sL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt install -y nodejs
else
# 判断版本是否小于或者等于22
if [[ $major -lt 22 ]]; then
echo "nodejs版本小于22，当前版本号为：$NODE_VERSION"
echo "您可以选择继续使用当前稳定版本不进行升级为22非稳定版本"
echo "请选择是否安装（yes/no）"
# yes/n判断
while true; do
read user_input
if [ "$user_input" == "yes" ] || [ "$user_input" == "y" ]; then
echo '正在安装中'
sudo apt remove -y libnode-dev
curl -sL https://deb.nodesource.com/setup_22.x | sudo -E bash -
sudo apt install -y nodejs
echo '安装完毕'
break
elif [ "$user_input" == "no" ] || [ "$user_input" == "n" ]; then
break
else
echo "输入错误，请输入yes或no:"
fi
done
else
echo "当前node版本：$NODE_VERSION，无需升级"
fi
fi
fi

# 检查pnpm是否已安装
if ! type pnpm >/dev/null 2>&1; then
echo 'pnpm未安装'
echo '正在安装pnpm中'
# 安装pnpm
npm --registry=https://registry.npmmirror.com install pnpm -g
else
echo 'pnpm已安装，跳过安装步骤'
fi

# 检查git是否已经安装
if command -v git >/dev/null 2>&1; then
echo "Git已经安装，跳过安装步骤"
else
echo "Git未安装，开始进行安装"
sudo apt install -y git
echo "Git安装完成"
fi

# 检查redis-server是否已安装
if dpkg -l | grep -q "^ii  redis-server"; then
echo "redis-server已安装，跳过安装步骤"
if [ $(which systemctl) ] && [ $(systemctl is-enabled redis-server) == "enabled" ]; then
echo "redis已开启自启，取消设置"
else
sudo systemctl enable redis-server
echo '设置redis自启服务'
fi
else
echo "正在安装redis数据库"
sudo apt install -y redis-server
echo "正在设置redis自启服务"
sudo systemctl enable redis-server
echo '设置成功'
fi

if dpkg -l | grep -q "^ii  fonts-wqy-microhei"; then
echo "fonts-wqy-microhei已安装，跳过安装步骤"
echo '中文字体安装完毕'
else
echo '正在安装中文字体-文泉驿微米黑中'
sudo apt install -y fonts-wqy-microhei
echo "fonts-wqy-microhei安装完成"
fi

echo "请选择是否重置字体缓存，初次安装请yes(yes或no)"

while true; do
read user_input
if [ "$user_input" == "yes" ] || [ "$user_input" == "y" ]; then
echo '正在重置字体缓存中'
sudo fc-cache -f -v
echo '中文字体设置完毕'
break
elif [ "$user_input" == "no" ] || [ "$user_input" == "n" ]; then
break
else
echo "输入错误，请输入yes或no:"
fi
done

# 安装screen
which screen > /dev/null
if [ $? -ne 0 ]; then
echo "screen未安装，正在安装中..."
sudo apt install -y screen
else
echo "screen已安装，跳过安装步骤"
fi

# 安装大象数据库
if ! dpkg -l | grep -qw postgresql; then
echo "postgresql未安装，正在安装中..."
sudo apt install -y postgresql postgresql-contrib
else
echo "postgresql已安装，跳过安装步骤"
fi

# 判断redis是否启动
if pgrep "redis-server" >/dev/null; then
echo "已启动，跳过"
else
echo "正在启动redis数据库."
sudo systemctl start redis-server
fi

echo "等待3秒继续..."
sleep 3