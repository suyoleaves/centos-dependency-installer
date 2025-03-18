# centos-dependency-checker

## CentOS 依赖离线包生成器
### 简介
本项目为无法联网或无Yum源的CentOS环境提供依赖包离线解决方案。通过生成本地Yum仓库离线包，用户可在无网络环境下快速安装指定依赖。适用于企业内网、隔离环境或网络受限场景。
（打工时给客户写的，现在稍微改动了一下搬到了github上）
### 核心功能
离线包生成：根据依赖清单自动生成包含所有依赖RPM包的离线仓库。
离线安装：无需网络连接，直接使用生成的离线包安装依赖。
CentOS兼容：支持CentOS 7+系统。
自动化测试：通过GitHub Actions验证脚本可靠性。
 
### 快速开始
1. 安装依赖工具
在可联网的CentOS机器上运行以下命令安装必要工具：
```bash
sudo yum install -y yum-utils createrepo
```
2. 配置依赖清单
编辑 dependencies.txt 文件，列出需要的依赖包（每行一个包名，支持注释）：
```bash # 示例依赖清单
bash
nc
curl
telnet
openssh
# 可选注释（以#开头）
# rpm-build
```
3. 生成离线仓库包
运行生成脚本：
```bash
# 赋予脚本执行权限
chmod +x generate_yum_repo.sh

# 执行生成命令
./generate_yum_repo.sh -f dependencies.txt
```
4. 离线安装依赖
将生成的 .tar.gz 离线包拷贝到目标机器，执行安装脚本：
```bash
# 赋予脚本执行权限
chmod +x install_dependency.sh

# 执行安装命令（替换路径）
./install_dependency.sh -f /path/to/agent_yum_repo_20240101123456.tar.gz
```
### GitHub Actions 用法
1. 自动化测试流程
本项目通过GitHub Actions实现以下自动化测试：
Docker容器测试：在CentOS 7容器中验证脚本兼容性。
依赖安装测试：自动生成离线包并验证安装流程。
2. 查看测试结果
访问项目的 Actions 标签页，查看最近的测试状态。
成功的测试会输出离线包路径和安装日志。
 
### 注意事项
依赖文件格式 dependencies.txt 中每行一个包名，支持注释（以#开头）和空行。
权限问题 执行脚本前请确保脚本有执行权限：
```bash
chmod +x generate_yum_repo.sh install_dependency.sh
  ```

### TODO
- [ ] 支持通过Gitlab Actions生成离线仓库
