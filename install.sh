#!/bin/bash
#颜色变量
Hong='\033[0;31m'  # 红色
Lan='\033[0;34m'   # 蓝色
Huang='\033[0;33m' # 黄色
Lu='\033[0;32m'    # 绿色
Zi='\033[0;35m'    # 紫色
Fen='\033[0;95m'   # 粉色
#恢复颜色
RESET_COLOR='\033[0m'
architecture=$(uname -m)
if [ "$architecture" == "x86_64" ]; then
echo -e "${Lan}当前架构为AMD${RESET_COLOR}"
else
echo -e "${Hong}当前架构为ARM${RESET_COLOR}"
fi

# 检查git是否已经安装
if command -v git >/dev/null 2>&1; then
echo -e "${Huang}Git已经安装，跳过安装步骤${RESET_COLOR}"
else
echo -e "${Hong}Git未安装，开始进行安装${RESET_COLOR}"
sudo apt install -y git
echo -e "${Lan}Git安装完成${RESET_COLOR}"
fi

distro=$(lsb_release -si)
version=$(lsb_release -sr)
major_version=$(echo $version | cut -d. -f1)
minor_version=$(echo $version | cut -d. -f2)
    
# 判断是否为Ubuntu系统且主版本号大于等于20
if [ "$distro" = "Ubuntu" ] && [ $major_version -ge 20 ]; then
echo -e "${Lu}当前Ubuntu版本为：$version{RESET_COLOR}"
else
echo -e "${Hong}⚠️⚠️⚠️：当前非 Ubuntu，请更换Ubuntu发行版再试${RESET_COLOR}"
exit 0
fi

# 判断列表是否为最新
echo -e "${Hong}正在检查apt列表...${RESET_COLOR}"
if ! sudo apt list --upgradable -a 2>/dev/null | grep -q "Listing..."; then
echo -e "${Hong}正在更新apt列表..."
echo -e "${Hong}接下来安装时间较长且无输出请耐心等待...${RESET_COLOR}"
sudo apt update -y 2>/dev/null
else
echo -e "${Lan}apt列表已是最新，跳过${RESET_COLOR}"
fi

echo -e "${Hong}正在安装部分依赖包...${RESET_COLOR}"
packages=(apt-transport-https curl ca-certificates software-properties-common)
for package in "${packages[@]}"; do
if dpkg -s "$package" >/dev/null 2>&1; then
echo -e "${Lan}${package} 已安装，跳过${RESET_COLOR}"
else
echo -e "${Hong}${package} 未安装，正在安装...${RESET_COLOR}"
sudo apt install -y "$package" 2>/dev/null
fi
done
echo -e "${Lan}依赖包已安装，跳过${RESET_COLOR}"
echo -e "${Lan}安装完成...${RESET_COLOR}"

echo -e "${Hong}正在检查已安装的软件包是否有更新...${RESET_COLOR}"
if ! sudo apt list --upgradable -a 2>/dev/null | grep -q "Listing..."; then
echo -e "${Hong}正在升级已安装的软件包...${RESET_COLOR}"
sudo apt upgrade -y 2>/dev/null
else
echo -e "${Lan}已是最新，跳过${RESET_COLOR}"
fi

# 检查ffmpeg是否已经安装
if command -v ffmpeg >/dev/null 2>&1; then
echo -e "${Huang}ffmpeg已经安装，跳过安装步骤${RESET_COLOR}"
else
echo -e "${Hong}ffmpeg未安装，开始进行安装${RESET_COLOR}"
sudo apt install -y ffmpeg
echo -e "${Lan}ffmpeg安装完成${RESET_COLOR}"
fi

# 检查nodejs是否已经安装
if [ -z "$(command -v node)" ]; then
echo -e "${Huang}nodejs未安装，开始安装...${RESET_COLOR}"
# 安装nodejs
sudo apt remove -y libnode-dev
curl -sL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt install -y nodejs
else
echo -e "${Huang}nodejs已安装，检查版本...${RESET_COLOR}"
# 获取nodejs的版本信息
NODE_VERSION=$(node -v | grep -oE "[0-9]+\.[0-9]+\.[0-9]+")
IFS='.' read -r major minor patch <<< "$NODE_VERSION"
major=$((10#$major))
minor=$((10#$minor))
patch=$((10#$patch))

# 判断版本是否大于或等于20
if [[ $major -lt 20 ]]; then
echo -e "${Hong}nodejs版本小于20，重新安装nodejs20中...${RESET_COLOR}"
# 安装nodejs
sudo apt remove -y libnode-dev
curl -sL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt install -y nodejs
else
# 判断版本是否小于或者等于22
if [[ $major -lt 22 ]]; then
echo -e "${Lu}nodejs版本小于22，当前版本号为：$NODE_VERSION"
echo "您可以选择继续使用当前稳定版本不进行升级为22非稳定版本"
echo "请选择是否安装（yes/no）${RESET_COLOR}"
# yes/n判断
while true; do
read user_input
if [ "$user_input" == "yes" ] || [ "$user_input" == "y" ]; then
echo -e "${Hong}正在安装中${RESET_COLOR}"
sudo apt remove -y libnode-dev
curl -sL https://deb.nodesource.com/setup_22.x | sudo -E bash -
sudo apt install -y nodejs
echo -e "${Lan}安装完毕${RESET_COLOR}"
break
elif [ "$user_input" == "no" ] || [ "$user_input" == "n" ]; then
break
else
echo -e "${Hong}输入错误，请输入yes或no:${RESET_COLOR}"
fi
done
else
echo -e "${Lu}当前node版本：$NODE_VERSION，无需升级${RESET_COLOR}"
fi
fi
fi

# 检查pnpm是否已安装
if ! type pnpm >/dev/null 2>&1; then
echo -e "${Hong}pnpm未安装"
echo -e "${Hong}正在安装pnpm中${RESET_COLOR}"
# 安装pnpm
npm --registry=https://registry.npmmirror.com install pnpm -g
else
echo -e "${Huang}pnpm已安装，跳过安装步骤${RESET_COLOR}"
fi

# 检查net-tools是否已安装
if ! type netstat >/dev/null 2>&1; then
echo -e "${Hong}net-tools未安装"
echo -e "${Hong}正在安装net-tools中${RESET_COLOR}"
apt install net-tools -y
echo -e "${Lan}net-tools安装完成${RESET_COLOR}"
else
echo -e "${Huang}net-tools已安装，跳过安装步骤${RESET_COLOR}"
fi

# 检查redis-server是否已安装
if dpkg -l | grep -q "^ii  redis-server"; then
echo -e "${Huang}redis-server已安装，跳过安装步骤${RESET_COLOR}"
if [ $(which systemctl) ] && [ $(systemctl is-enabled redis-server) == "enabled" ]; then
echo -e "${Huang}redis已开启自启，取消设置${RESET_COLOR}"
else
sudo systemctl enable redis-server
echo -e "${Hong}已设置redis自启服务${RESET_COLOR}"
fi
else
echo -e "${Hong}正在安装redis数据库${RESET_COLOR}"
sudo apt install -y redis-server
echo -e "${Hong}正在设置redis自启服务${RESET_COLOR}"
sudo systemctl enable redis-server
echo -e "${Lan}设置成功${RESET_COLOR}"
fi

if dpkg -l | grep -q "^ii  fonts-wqy-microhei"; then
echo -e "${Huang}fonts-wqy-microhei 已安装，跳过安装步骤${RESET_COLOR}"
else
echo -e "${Hong}正在安装中文字体 - 文泉驿微米黑中${RESET_COLOR}"
sudo apt update && sudo apt install -y fonts-wqy-microhei
echo -e "${Lan}fonts-wqy-microhei 安装完成${RESET_COLOR}"
echo -e "${Hong}正在重置字体缓存中${RESET_COLOR}"
sudo fc-cache -f -v
echo -e "${Lan}中文字体设置完毕${RESET_COLOR}"
fi

# 安装screen
which screen > /dev/null
if [ $? -ne 0 ]; then
echo -e "${Hong}screen未安装，正在安装中...${RESET_COLOR}"
sudo apt install -y screen
else
echo -e "${Huang}screen已安装，跳过安装步骤${RESET_COLOR}"
fi

# 安装大象数据库
if ! dpkg -l | grep -qw postgresql; then
echo -e "${Hong}postgresql未安装，正在安装中...${RESET_COLOR}"
sudo apt install -y postgresql postgresql-contrib
else
echo -e "${Huang}postgresql已安装，跳过安装步骤${RESET_COLOR}"
fi

# 判断redis是否启动
if pgrep "redis-server" >/dev/null; then
echo -e "${Huang}已启动，跳过${RESET_COLOR}"
else
echo -e "${Hong}正在启动redis数据库.${RESET_COLOR}"
sudo systemctl start redis-server
fi

sleep 1
echo -e "${Lan}安装完毕${RESET_COLOR}"
