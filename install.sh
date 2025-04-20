#!/bin/bash
export PYTHONUNBUFFERED=1
exec > >(tee -a install.log) 2>&1

# 颜色变量
Hong='\033[0;31m'  # 红色
Lan='\033[0;34m'   # 蓝色
Huang='\033[0;33m' # 黄色
Lu='\033[0;32m'    # 绿色
Zi='\033[0;35m'    # 紫色
Fen='\033[0;95m'   # 粉色
Qing='\033[0;36m'  # 青色

# 恢复颜色
RESET_COLOR='\033[0m'

# 检查是否为root用户并明确提示
if [ "$(id -u)" -ne 0 ]; then
echo -e "${Hong}当前用户: $(whoami)${RESET_COLOR}"
echo -e "${Hong}需要sudo权限，正在提升权限...${RESET_COLOR}"
if sudo -n true 2>/dev/null; then
echo -e "${Lu}已有sudo权限${RESET_COLOR}"
else
echo -e "${Huang}正在请求密码...${RESET_COLOR}"
 exec sudo su -c "bash $0 $@" || {
echo -e "${Hong}提升权限失败${RESET_COLOR}"
exit 1
}
fi
else
echo -e "${Qing}当前已是root用户${RESET_COLOR}"
fi

# 判断系统架构
architecture=$(uname -m)
if [ "$architecture" == "x86_64" ]; then
echo -e "${Qing}当前架构为AMD${RESET_COLOR}"
else
echo -e "${Qing}当前架构为ARM${RESET_COLOR}"
fi

# 检查Git是否已经安装
if command -v git >/dev/null 2>&1; then
echo -e "${Lan}Git已安装，跳过安装步骤${RESET_COLOR}"
else
echo -e "${Huang}Git未安装，开始进行安装${RESET_COLOR}"
sudo apt install -y git
echo -e "${Lu}Git安装完成${RESET_COLOR}"
fi

# 获取发行版信息
distro=$(lsb_release -si)
version=$(lsb_release -sr)
major_version=$(echo $version | cut -d. -f1)
minor_version=$(echo $version | cut -d. -f2)
    
# 检查系统是否为Ubuntu或Debian
if [ "$distro" = "Ubuntu" ] || [ "$distro" = "Debian" ]; then
if [ "$distro" = "Ubuntu" ] && [ $major_version -ge 20 ]; then
echo -e "${Qing}当前Ubuntu版本为：$version ${Huang}系统版本正确，继续安装√${RESET_COLOR}"
elif [ "$distro" = "Debian" ] && [ $major_version -ge 10 ]; then
echo -e "${Qing}当前Debian版本为：$version ${Huang}系统版本正确，继续安装√${RESET_COLOR}"
else
echo -e "${Hong}⚠️⚠️⚠️：当前系统版本过低，请升级系统后再试"
echo -e "Ubuntu20.04 + && Debian 10+${RESET_COLOR}"
exit 0
fi
else
echo -e "${Hong}⚠️⚠️⚠️：当前非 Ubuntu 或 Debian 发行版，请更换发行版再试${RESET_COLOR}"
exit 0
fi

# 判断apt列表是否为最新
echo -e "${Huang}正在检查apt列表...${RESET_COLOR}"
if ! sudo apt list --upgradable -a 2>/dev/null | grep -q "Listing..."; then
echo -e "${Huang}正在更新apt列表..."
echo -e "接下来安装时间较长且无输出请耐心等待...${RESET_COLOR}"
sudo apt update -y 2>/dev/null
else
echo -e "${Lan}apt列表已是最新，跳过${RESET_COLOR}"
fi
echo -e "${Huang}正在安装部分依赖包...${RESET_COLOR}"
packages=(apt-transport-https curl ca-certificates)
for package in "${packages[@]}"; do
if dpkg -s "$package" >/dev/null 2>&1; then
echo -e "${Lan}${package} 已安装，跳过${RESET_COLOR}"
else
echo -e "${Huang}${package} 未安装，正在安装...${RESET_COLOR}"
sudo apt install -y "$package" 2>/dev/null
fi
done
echo -e "${Lan}依赖包已安装，跳过${RESET_COLOR}"
echo -e "${Lu}安装完成...${RESET_COLOR}"
echo -e "${Huang}正在检查已安装的软件包是否有更新...${RESET_COLOR}"
if ! sudo apt list --upgradable -a 2>/dev/null | grep -q "Listing..."; then
echo -e "${Huang}正在升级已安装的软件包...${RESET_COLOR}"
sudo apt upgrade -y 2>/dev/null
else
echo -e "${Lan}已是最新，跳过${RESET_COLOR}"
fi

# Nodejs安装
if [ -z "$(command -v node)" ]; then
echo -e "${Huang}Nodejs未安装，是否安装最新版23（yes）或稳定版22（no）？${RESET_COLOR}"
read -t 3 user_input || user_input="no"
if [ "$user_input" == "yes" ] || [ "$user_input" == "y" ]; then
echo -e "${Huang}正在安装Nodejs 23...${RESET_COLOR}"
sudo apt remove -y libnode-dev
curl -sL https://deb.nodesource.com/setup_23.x | sudo -E bash -
sudo apt install -y nodejs
echo -e "${Lu}Nodejs 23安装完毕${RESET_COLOR}"
elif [ "$user_input" == "no" ] || [ "$user_input" == "n" ]; then
echo -e "${Huang}正在安装Nodejs 22...${RESET_COLOR}"
sudo apt remove -y libnode-dev
curl -sL https://deb.nodesource.com/setup_22.x | sudo -E bash -
sudo apt install -y nodejs
echo -e "${Lu}Nodejs 22安装完毕${RESET_COLOR}"
else
echo -e "${Hong}输入错误，请输入yes或no:${RESET_COLOR}"
fi
else
echo -e "${Lan}Nodejs已安装，${Huang}检查版本...${RESET_COLOR}"
NODE_VERSION=$(node -v | grep -oE "[0-9]+\.[0-9]+\.[0-9]+")
IFS='.' read -r major minor patch <<< "$NODE_VERSION"
major=$((10#$major))
minor=$((10#$minor))
patch=$((10#$patch))

if [[ $major -lt 22 ]]; then
echo -e "${Huang}当前Nodejs版本为 $NODE_VERSION，低于22。是否安装最新版23（yes）或稳定版22（no）？${RESET_COLOR}"
read -t 3 user_input || user_input="no"
if [ "$user_input" == "yes" ] || [ "$user_input" == "y" ]; then
echo -e "${Huang}正在安装Nodejs 23...${RESET_COLOR}"
sudo apt remove -y libnode-dev
curl -sL https://deb.nodesource.com/setup_23.x | sudo -E bash -
sudo apt install -y nodejs
echo -e "${Lu}Nodejs 23安装完毕${RESET_COLOR}"
elif [ "$user_input" == "no" ] || [ "$user_input" == "n" ]; then
echo -e "${Huang}正在安装Nodejs 22...${RESET_COLOR}"
sudo apt remove -y libnode-dev
curl -sL https://deb.nodesource.com/setup_22.x | sudo -E bash -
sudo apt install -y nodejs
echo -e "${Lu}Nodejs 22安装完毕${RESET_COLOR}"
else
echo -e "${Hong}输入错误，请输入yes或no:${RESET_COLOR}"
fi
else
echo -e "${Qing}当前Nodejs版本为 $NODE_VERSION，无需升级${RESET_COLOR}"
fi
fi

# 检查pnpm是否已安装
if ! type pnpm >/dev/null 2>&1; then
echo -e "${Huang}pnpm未安装，开始安装pnpm...${RESET_COLOR}"
npm --registry=https://registry.npmmirror.com install pnpm -g
echo -e "${Lu}pnpm安装完成${RESET_COLOR}"
echo -e "${Huang}正在设置pnpm镜像源${RESET_COLOR}"
pnpm config set registry https://registry.npmmirror.com
echo -e "${Lu}设置完毕${RESET_COLOR}"
else
echo -e "${Lan}pnpm已安装，跳过安装步骤${RESET_COLOR}"
fi

# 获取当前Python版本
current_python_version=$(python3 --version 2>&1)

# 检查Python版本
current_python_version=$(python3 --version 2>&1)
if [[ "$current_python_version" == *"command not found"* ]]; then
echo -e "${Hong}Python3未安装${RESET_COLOR}"
exit 1
elif [[ "$current_python_version" == *"permission denied"* ]]; then
echo -e "${Hong}权限不足${RESET_COLOR}"
exit 1
elif [[ "$current_python_version" != *"Python 3.10"* ]]; then
echo -e "${Hong}检测到Python版本: ${current_python_version}${RESET_COLOR}"
echo -e "${Huang}是否安装Python 3.10? (y/n)${RESET_COLOR}"
read -t 5 user_input || user_input="n"
if [[ "$user_input" =~ ^[yY] ]]; then
echo -e "${Huang}开始安装Python 3.10...${RESET_COLOR}"
if ! sudo add-apt-repository -y ppa:deadsnakes/ppa; then
echo -e "${Hong}PPA添加失败${RESET_COLOR}"
exit 1
fi
sudo apt update
if sudo apt install -y python3.10 python3.10-distutils python3.10-venv; then
echo -e "${Lu}Python 3.10安装成功${RESET_COLOR}"
echo -e "${Huang}是否要将Python 3.10设置为默认版本？ (y/n)${RESET_COLOR}"
read -t 3 default_input || default_input="y"
if [[ "$default_input" =~ ^[yY] ]]; then
sudo update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.10 2
sudo update-alternatives --set python3 /usr/bin/python3.10
echo -e "${Lu}已设为默认版本${RESET_COLOR}"
fi
else
echo -e "${Hong}安装失败${RESET_COLOR}"
fi
else
echo -e "${Lan}跳过安装${RESET_COLOR}"
fi
else
echo -e "${Qing}当前Python版本：${current_python_version}，${Lan}跳过...${RESET_COLOR}"
fi

# 检查net-tools是否已安装
if ! type netstat >/dev/null 2>&1; then
echo -e "${Huang}net-tools未安装，正在安装net-tools中${RESET_COLOR}"
apt install net-tools -y
echo -e "${Lu}net-tools安装完成${RESET_COLOR}"
else
echo -e "${Lan}net-tools已安装，跳过安装步骤${RESET_COLOR}"
fi

# 检查redis数据库是否已安装
if dpkg -l | grep -q "^ii  redis-server"; then
echo -e "${Lan}redis-server已安装，跳过安装步骤${RESET_COLOR}"
if [ $(which systemctl) ] && [ $(systemctl is-enabled redis-server) == "enabled" ]; then
echo -e "${Lan}redis已开启自启，取消设置${RESET_COLOR}"
else
echo -e "${Huang}正在设置redis自启服务${RESET_COLOR}"
sudo systemctl enable redis-server
echo -e "${Lu}设置redis自启服务成功${RESET_COLOR}"
fi
else
echo -e "${Huang}正在安装redis数据库${RESET_COLOR}"
sudo apt install -y redis-server
echo -e "${Huang}正在设置redis自启服务${RESET_COLOR}"
sudo systemctl enable redis-server
echo -e "${Lu}设置成功${RESET_COLOR}"
fi

# 检查中文字体是否安装
if dpkg -l | grep -q "^ii  fonts-wqy-microhei"; then
echo -e "${Lan}fonts-wqy-microhei 已安装，跳过安装步骤${RESET_COLOR}"
else
echo -e "${Huang}正在安装中文字体 - 文泉驿微米黑中${RESET_COLOR}"
sudo apt update && sudo apt install -y fonts-wqy-microhei
echo -e "${Lu}fonts-wqy-microhei 安装完成${RESET_COLOR}"
echo -e "${Huang}正在重置字体缓存中${RESET_COLOR}"
sudo fc-cache -f -v
echo -e "${Lu}中文字体设置完毕${RESET_COLOR}"
fi

# 安装剩余所需包
packages=(lsof ffmpeg screen postgresql postgresql-contrib ca-certificates fonts-liberation libasound2 libatk-bridge2.0-0 libatk1.0-0 libc6 libcairo2 libcups2 libdbus-1-3 libexpat1 libfontconfig1 libgbm1 libgcc-s1 libglib2.0-0 libgtk-3-0 libnspr4 libnss3 libpango-1.0-0 libpangocairo-1.0-0 libstdc++6 libx11-6 libx11-xcb1 libxcb1 libxcomposite1 libxcursor1 libxdamage1 libxext6 libxfixes3 libxi6 libxrandr2 libxrender1 libxss1 libxtst6 lsb-release wget xdg-utils libxkbcommon0)
for package in "${packages[@]}"; do
if dpkg -s "$package" >/dev/null 2>&1; then
echo -e "${Lan}${package} 已安装，跳过${RESET_COLOR}"
else
echo -e "${Huang}${package} 未安装，正在安装...${RESET_COLOR}"
sudo apt install -y "$package" 2>/dev/null
fi
done
echo -e "${Lan}依赖包已全部安装，跳过${RESET_COLOR}"
echo -e "${Lu}安装完成...${RESET_COLOR}"

# 等待全部完成
echo -e "${Hong}等待1秒继续...${RESET_COLOR}"
sleep 1