# arm 版本 st2 packages 
这个项目就是个docker-compose，用来启动packagingbuild和packagingrunner。

## 重要引用

- 基于Docker。利用Docker，可以快速可靠地为任何操作系统发行版交付软件包。使用最新版本的Docker，并配有支持V2语法的Docker Compose插件。

- 基于Rake和sshkit的执行方式使得通过简单的DSL（领域特定语言）进行配置变得容易，并且内置了并行任务处理。

- 测试驱动的工作流程。构建的工件不仅可以用于任何已启用的操作系统发行版，还同时在多个平台上进行测试，提供诸如是否可以安装、服务是否可以启动、操作是否可以执行等反馈。
## 概述
要使用这个docker-compose，需要安装特定版本的Docker19.03.14以及Docker Compose在Ubuntu上

## 安装Docker 19.03.14
### 步骤1：添加Docker的APT仓库
首先，您需要将Docker的APT仓库添加到Ubuntu系统中。这可以通过以下命令完成：
```shell
sudo install -m 0755 -d /etc/apt/keyrings
sudo apt-get -y install ca-certificates curl
sudo curl -fsSL http://mirrors.cloud.aliyuncs.com/docker-ce/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc
echo   "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] http://mirrors.cloud.aliyuncs.com/docker-ce/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" |   sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
```
### 步骤2：更新APT包索引
使用以下命令更新您的APT包索引：
```shell
sudo apt-get update
```
### 步骤3：安装Docker Engine
通过指定版本来安装Docker Engine：
```shell
sudo apt-get install -y docker-ce=5:19.03.14~3-0~ubuntu-focal docker-ce-cli=5:19.03.14~3-0~ubuntu-focal containerd.io
```
注意：版本号 5:19.03.14~3-0~ubuntu-focal 应与您要安装的Docker版本匹配。如果版本不匹配或无法找到，您可能需要检查Docker仓库中是否包含了您所需的版本。
### 步骤4：验证Docker安装
使用以下命令验证Docker是否已正确安装：
```shell
docker --version
```

### 安装Docker Compose
下载安装
```shell
https://github.com/docker/compose/releases/download/v2.17.2/docker-compose-linux-aarch64
sudo chmod +x /usr/local/bin/docker-compose
```

## 使用Docker-compose启动打包
因为我只做了ubuntu focal的arm适配，所以目前只能构建deb包
```shell
# (Optional) First clean out previous build containers
docker-compose kill
docker-compose rm -f

# To build packages for ubuntu focal (--rm will wipe packaging runner container. All others will remain active).
docker-compose run --rm focal
```

执行需要一段时间，所以拿一杯茶或咖啡，等到它完成。当构建和测试过程成功时，您将在主机上的“/tmp/st2-packages”中找到 StackStorm 包：
```shell
ls -l1 | grep ".deb$"
-rw-r--r-- 1 root root 30872652 Feb  9 18:32 st2_1.4dev-1_amd64.deb
```
至此 st2的deb包就构建完成了，可以进行安装和测试。

## 在 docker 环境中进行手动测试，测试步骤也可省略，直接在arm环境上安装测试也可以

在构建和测试阶段完成后，所有 docker 容器都保持活动状态，因此，如果需要，欢迎您进行更深入的测试。为此，只需运行：
```
docker ps
# Find the required testing container
# In our case it will be st2packages_focaltest_1

# Simply exec to docker
docker exec -it st2packages_focaltest_1 bash
```

完成后，您将进入测试环境，所有服务都已启动并运行。别忘了做（在exec之后）：
```
export TERM=xterm
```
此时，您可以执行所需的任何手动测试。

