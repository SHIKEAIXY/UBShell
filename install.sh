#!/bin/bash
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

echo -e "${Hong}通知："
echo -e "蓝色为：正常输出，代表无需进行的处理"
echo -e "黄色为：正常输出，代表正在进行的任务"
echo -e "绿色为：正常输出，代表完成的任务"
echo -e "紫色为：正常输出，代表特殊的数据相关提示"
echo -e "青色为：正常输出，代表系统/版本相关提示"
echo -e "红色为：异常输出，代表处理失败/重要提示${RESET_COLOR}"

# 判断系统架构
architecture=$(uname -m)
if [ "$architecture" == "x86_64" ]; then
echo -e "${Qing}当前架构为AMD${RESET_COLOR}"
else
echo -e "${Hong}⚠️⚠️⚠️：当前架构为ARM"
echo -e "在ARM上可能无法正常部署成功?${RESET_COLOR}"
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
echo -e "Ubuntu20+ && Debian 10+${RESET_COLOR}"
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
packages=(apt-transport-https curl ca-certificates git)
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

# 检查Nodejs是否已经安装
if [ -z "$(command -v node)" ]; then
echo -e "${Huang}Nodejs未安装，是否安装最新版23（yes）或稳定版22（no）？${RESET_COLOR}"
while true; do
read user_input
if [ "$user_input" == "yes" ] || [ "$user_input" == "y" ]; then
echo -e "${Huang}正在安装Nodejs 23...${RESET_COLOR}"
sudo apt remove -y libnode-dev
curl -sL https://deb.nodesource.com/setup_23.x | sudo -E bash -
sudo apt install -y nodejs
echo -e "${Lu}Nodejs 23安装完毕${RESET_COLOR}"
break
elif [ "$user_input" == "no" ] || [ "$user_input" == "n" ]; then
echo -e "${Huang}正在安装Nodejs 22...${RESET_COLOR}"
sudo apt remove -y libnode-dev
curl -sL https://deb.nodesource.com/setup_22.x | sudo -E bash -
sudo apt install -y nodejs
echo -e "${Lu}Nodejs 22安装完毕${RESET_COLOR}"
break
else
echo -e "${Hong}输入错误，请输入yes或no:${RESET_COLOR}"
fi
done
else
echo -e "${Lan}Nodejs已安装，${Huang}检查版本...${RESET_COLOR}"
# 获取Nodejs的版本信息
NODE_VERSION=$(node -v | grep -oE "[0-9]+\.[0-9]+\.[0-9]+")
IFS='.' read -r major minor patch <<< "$NODE_VERSION"
major=$((10#$major))
minor=$((10#$minor))
patch=$((10#$patch))

# 判断版本是否低于22
if [[ $major -lt 22 ]]; then
echo -e "${Huang}当前Nodejs版本为 $NODE_VERSION，低于22。是否安装最新版23（yes）或稳定版22（no）？${RESET_COLOR}"
while true; do
read user_input
if [ "$user_input" == "yes" ] || [ "$user_input" == "y" ]; then
echo -e "${Huang}正在安装Nodejs 23...${RESET_COLOR}"
sudo apt remove -y libnode-dev
curl -sL https://deb.nodesource.com/setup_23.x | sudo -E bash -
sudo apt install -y nodejs
echo -e "${Lu}Nodejs 23安装完毕${RESET_COLOR}"
break
elif [ "$user_input" == "no" ] || [ "$user_input" == "n" ]; then
echo -e "${Huang}正在安装Nodejs 22...${RESET_COLOR}"
sudo apt remove -y libnode-dev
curl -sL https://deb.nodesource.com/setup_22.x | sudo -E bash -
sudo apt install -y nodejs
echo -e "${Lu}Nodejs 22安装完毕${RESET_COLOR}"
break
else
echo -e "${Hong}输入错误，请输入yes或no:${RESET_COLOR}"
fi
done
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
current_python_version=$(python3 --version)

# 检查Python版本是否为3.10
if [[ "$current_python_version" != *"Python 3.10"* ]]; then
echo -e "${Hong}当前Python版本：${current_python_version}，版本建议Python 3.10${RESET_COLOR}"
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
# 判断redis是否启动
if pgrep "redis-server" >/dev/null; then
echo -e "${Lan}redis服务已启动，跳过${RESET_COLOR}"
else
echo -e "${Luang}正在启动redis数据库.${RESET_COLOR}"
sudo systemctl start redis-server
echo -e "${Lan}redis服务启动成功${RESET_COLOR}"
fi

# 等待全部完成
sleep 1

echo -e "${Zi}已全部完成...${RESET_COLOR}"