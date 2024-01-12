#!/bin/bash

# 检查是否是基于Debian系列的操作系统
echo ">>> 检查是否是基于Debian系列的操作系统"
cat /etc/os-release | grep -i "debian" >/dev/null
if [ $? -ne 0 ]; then
    echo "此脚本仅支持基于Debian系列的操作系统"
    exit 1
fi

# 检查是否为root用户
echo ">>> 检查是否为root用户"
if [ $(id -u) != "0" ]; then
    echo "请使用root用户执行此脚本"
    exit 1
fi

# 安装依赖
echo ">>> 安装依赖"
apt update -y && apt full-upgrade -y
apt install -y ca-certificates curl gnupg

# 安装Docker
echo ">>> 安装Docker"
for pkg in docker.io docker-doc docker-compose podman-docker containerd runc; do sudo apt remove $pkg; done
install -m 0755 -d /etc/apt/keyrings
if [ -f /etc/apt/keyrings/docker.gpg ]; then
    rm -f /etc/apt/keyrings/docker.gpg
fi
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
chmod a+r /etc/apt/keyrings/docker.gpg
echo \
    "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" |
    tee /etc/apt/sources.list.d/docker.list >/dev/null
apt update -y
apt install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

# 获取脚本所在目录
echo ">>> 获取脚本所在目录"
work_dir=$(
    cd $(dirname $0)
    pwd
)
echo "脚本所在目录：${work_dir}"

# 安装MobSF
echo ">>> 安装MobSF"
mobsf_dir="${work_dir}/mobsf"
mkdir -p "${mobsf_dir}"
cd "${mobsf_dir}"

if [ -d Mobile-Security-Framework-MobSF ]; then
    echo ">>> 更新MobSF"
    cd Mobile-Security-Framework-MobSF
    rm -f docker-compose.yml
    git pull
    cd ..
else
    echo ">>> 克隆MobSF"
    git clone https://github.com/MobSF/Mobile-Security-Framework-MobSF.git
fi

# 替换MobSF的docker-compose.yml
echo ">>> 替换MobSF的docker-compose.yml"
rm -f Mobile-Security-Framework-MobSF/docker-compose.yml
cp docker-compose-mobsf.yml Mobile-Security-Framework-MobSF/docker-compose.yml

# 创建持久化目录
echo ">>> 创建持久化目录"
mobsf_db_vol="${mobsf_dir}/postgres/data"
mobsf_app_vol="${mobsf_dir}/.MobSF"
mkdir -p "${mobsf_db_vol}"
mkdir -p "${mobsf_app_vol}"
chown 9901:9901 "${mobsf_app_vol}"
sed -i "s#MOBSF_DB_VOL#${mobsf_db_vol}#g" Mobile-Security-Framework-MobSF/docker-compose.yml
sed -i "s#MOBSF_APP_VOL#${mobsf_app_vol}#g" Mobile-Security-Framework-MobSF/docker-compose.yml

# 构建镜像
echo ">>> 构建镜像"
cd Mobile-Security-Framework-MobSF
docker-compose build

# 启动容器
echo ">>> 启动容器"
docker-compose up -d
