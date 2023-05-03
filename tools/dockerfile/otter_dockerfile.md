## Docker Buildx

### Buildx简介

- docker buildx 是一个 docker CLI 插件，其扩展了 docker 命令
- 在 Docker 19.03+ 版本中可以使用 docker buildx build命令，底层是基于BuildKit的api 构建镜像。builx命令支持 --platform参数可以同时构建支持多种系统架构的 Docker 镜像，大大简化了构建步骤
- [buildx](https://github.com/docker/buildx)，可以很轻松地构建多平台 Docker 镜像。buildx 是 `docker build ...` 命令的下一代替代品，它利用 [BuildKit](https://github.com/moby/buildkit) 的全部功能扩展了 `docker build` 的功能
- `使用 docker buildx的前置条件`：docker版本>=19.03，Linux内核版本>=4.8， binfmt-support >= 2.1.7

### Buildx启用

```shell
# 先确保docker版本 >= 19.03
[root@k8s-master-1 demo1]# docker version
Client: Docker Engine - Community
 Version:           23.0.1

# 查看内核版本，内核需要>=4.8
[root@k8s-master-1 demo1]# uname -a
Linux k8s-master-1 5.14.0-162.6.1.el9_1.aarch64 #1 SMP PREEMPT_DYNAMIC Tue Nov 15 20:52:32 UTC 2022 aarch64 aarch64 aarch64 GNU/Linux

# 临时启用buildx
	export DOCKER_CLI_EXPERIMENTAL=enabled

# 永久启用
[root@k8s-master-1 docker-buildx]# cat /etc/docker/daemon.json
{
  "exec-opts": ["native.cgroupdriver=systemd"],
  "registry-mirrors": ["https://ornb7jit.mirror.aliyuncs.com"],
  "experimental": true   # 启用该参数
}

# 查看是否启用
[root@k8s-master-1 docker-buildx]# docker buildx version
github.com/docker/buildx v0.10.2 00ed17d
```

- 开启binfmt_misc来运行非本地架构Docker镜像

```shell
# 如果你是 Mac 或者 Windows 版本 Docker 桌面版，可以跳过这个步骤，因为 binfmt_misc 默认开启
# 如果你使用是 Linux 系统，需要设置 binfmt_misc。怎么设置？其实就是通过运行一个特权 Docker 容器，有了这个容器就相当于模拟了一个可以支持其他架构的镜像的运行环境

# 运行binfmt_misc容器
[root@k8s-master-1 demo1]# docker run --rm --privileged tonistiigi/binfmt:latest --install all
installing: arm OK
installing: s390x OK
installing: ppc64le OK
installing: amd64 OK
installing: 386 OK
installing: mips64le OK
installing: mips64 OK
installing: riscv64 OK
{
  "supported": [
    "linux/arm64",
    "linux/amd64",
    "linux/riscv64",
    "linux/ppc64le",
    "linux/s390x",
    "linux/386",
    "linux/mips64le",
    "linux/mips64",
    "linux/arm/v7",
    "linux/arm/v6"
  ],
  "emulators": [
    "qemu-arm",
    "qemu-i386",
    "qemu-mips64",
    "qemu-mips64el",
    "qemu-ppc64le",
    "qemu-riscv64",
    "qemu-s390x",
    "qemu-x86_64"
  ]
}
```

- 查看qemu相关文件，在 Linux 上，QEMU 除了可以模拟完整的操作系统之外，还有另外一种模式叫 用户态模式（User mod）。该模式下 QEMU 将通过 binfmt_misc 在 Linux 内核中注册一个二进制转换处理程序，并在程序运行时动态翻译二进制文件，根据需要将系统调用从目标 CPU 架构转换为当前系统的 CPU 架构。最终的效果看起来就像在本地运行目标 CPU 架构的二进制文件
- 通过 QEMU 的用户态模式，我们可以创建轻量级的虚拟机（ chroot 或容器），然后在虚拟机系统中编译程序，和本地编译一样简单轻松。后面我们就会看到，跨平台构建 Docker 镜像用的就是这个方法

```shell
# 查看qume相关文件
[root@k8s-master-1 demo1]# ls -al /proc/sys/fs/binfmt_misc/
total 0
drwxr-xr-x 2 root root 0 Feb 17 23:41 .
dr-xr-xr-x 1 root root 0 Feb 18  2023 ..
-rw-r--r-- 1 root root 0 Feb 17 23:41 qemu-arm
-rw-r--r-- 1 root root 0 Feb 17 23:41 qemu-i386
-rw-r--r-- 1 root root 0 Feb 17 23:41 qemu-mips64
-rw-r--r-- 1 root root 0 Feb 17 23:41 qemu-mips64el
-rw-r--r-- 1 root root 0 Feb 17 23:41 qemu-ppc64le
-rw-r--r-- 1 root root 0 Feb 17 23:41 qemu-riscv64
-rw-r--r-- 1 root root 0 Feb 17 23:41 qemu-s390x
-rw-r--r-- 1 root root 0 Feb 17 23:41 qemu-x86_64
--w------- 1 root root 0 Feb 17 23:41 register
-rw-r--r-- 1 root root 0 Feb 17 23:41 status

# 查看默认build构建器
[root@k8s-master-1 demo1]# docker buildx ls
NAME/NODE DRIVER/ENDPOINT STATUS  BUILDKIT PLATFORMS
default * docker
  default default         running 23.0.1   linux/arm64, linux/amd64, linux/amd64/v2, linux/riscv64, linux/ppc64le, linux/s390x, linux/386, linux/mips64le, linux/mips64, linux/arm/v7, linux/arm/v6

# 将默认 Docker 镜像构建器切换成多架构构建器，如果你想执行一次构建命令，打包出支持多个架构的镜像，那么就必须要做这一步，否则，当你--platform是多架构参数时，会报错
# 默认情况下，Docker 会使用旧的构建器，不支持多架构构建，为了创建一个新的支持多架构的构建器，需要运行
# moby/buildkit:master 适配了多架构
	docker buildx create --use --name=mybuilder --driver docker-container --driver-opt image=moby/buildkit:master 
```

### Buildx构建测试

```go
// go测试代码
// [root@k8s-master-1 demo1]# cat main.go
package main

import (
        "fmt"
        "runtime"
)

func main() {
        fmt.Printf("Hello, %s!\n", runtime.GOARCH)
}
```

- Dockerfile

```shell
[root@k8s-master-1 demo1]# cat Dockerfile
FROM --platform=$TARGETPLATFORM alpine
CMD ls /root
```

- 基于当前arm机器构建arm64和amd64

```shell
# 构建镜像并上传
[root@k8s-master-1 demo1]# docker buildx build -t registry.cn-hangzhou.aliyuncs.com/jiayu98/test:v1 --platform=linux/arm64,linux/amd64 . --push
[+] Building 8.6s (8/9)
 => [internal] load build definition from Dockerfile                                                                                          0.0s
 => => transferring dockerfile: 89B                                                                                                           0.0s
 => [internal] load .dockerignore                                                                                                             0.0s
 => => transferring context: 2B                                                                                                               0.0s
 => [linux/arm64 internal] load metadata for docker.io/library/alpine:latest                                                                  4.9s
 => [linux/amd64 internal] load metadata for docker.io/library/alpine:latest                                                                  4.7s
 => [linux/arm64 1/1] FROM docker.io/library/alpine@sha256:69665d02cb32192e52e07644d76bc6f25abeb5410edc1c7a81a10ba3f0efb90a                   3.6s
 => => resolve docker.io/library/alpine@sha256:69665d02cb32192e52e07644d76bc6f25abeb5410edc1c7a81a10ba3f0efb90a                               3.6s
 => => sha256:af6eaf76a39c2d3e7e0b8a0420486e3df33c4027d696c076a99a3d0ac09026af 3.26MB / 3.26MB                                                0.6s
 => [linux/amd64 1/1] FROM docker.io/library/alpine@sha256:69665d02cb32192e52e07644d76bc6f25abeb5410edc1c7a81a10ba3f0efb90a                   1.1s
 => => resolve docker.io/library/alpine@sha256:69665d02cb32192e52e07644d76bc6f25abeb5410edc1c7a81a10ba3f0efb90a                               0.0s
 => => sha256:63b65145d645c1250c391b2d16ebe53b3747c295ca8ba2fcb6b0cf064a4dc21c 3.37MB / 3.37MB                                                1.1s
 => exporting to image                                                                                                                        3.5s
 => => exporting layers                                                                                                                       0.0s
 => => exporting manifest sha256:e48ab472f08dbb194ff8a8be5bdfe6f45470a798ac68f473d8756f2a096f300e                                             0.0s
 => => exporting config sha256:b14d159f80dc613e9984a961244cd1f265edfc3e9df00745d96b5c87ba08674b                                               0.0s
 => => exporting manifest sha256:ee20d5c1f9272d82090b89ca820ba803d511de85fa224b1dc718e6fe53b41e17                                             0.0s
 => => exporting config sha256:a92ed0fa09ff30612a8c0887fa2f14bb433735b0a274fd74e9d83ef8a30c20bf                                               0.0s
 => => exporting manifest list sha256:72b4ad9e3463bd79d2f55c05f08d4d97ef638bde3aafa167ebe5a57e90761680                                        0.0s
 => => pushing layers                                                                                                                         2.7s
 => => pushing manifest for registry.cn-hangzhou.aliyuncs.com/jiayu98/test:v1@sha256:72b4ad9e3463bd79d2f55c05f08d4d97ef638bde3aafa167ebe5a57  0.8s
 => [auth] jiayu98/test:pull,push token for registry.cn-hangzhou.aliyuncs.com                                                                 0.0s
 => [auth] jiayu98/test:pull,push token for registry.cn-hangzhou.aliyuncs.com

# 查看镜像信息，可以发现同事构建了arm64和amd64的镜像
[root@k8s-master-1 demo1]# docker buildx imagetools inspect registry.cn-hangzhou.aliyuncs.com/jiayu98/test:v1
Name:      registry.cn-hangzhou.aliyuncs.com/jiayu98/test:v1
MediaType: application/vnd.docker.distribution.manifest.list.v2+json
Digest:    sha256:72b4ad9e3463bd79d2f55c05f08d4d97ef638bde3aafa167ebe5a57e90761680

Manifests:
  Name:      registry.cn-hangzhou.aliyuncs.com/jiayu98/test:v1@sha256:e48ab472f08dbb194ff8a8be5bdfe6f45470a798ac68f473d8756f2a096f300e
  MediaType: application/vnd.docker.distribution.manifest.v2+json
  Platform:  linux/arm64

  Name:      registry.cn-hangzhou.aliyuncs.com/jiayu98/test:v1@sha256:ee20d5c1f9272d82090b89ca820ba803d511de85fa224b1dc718e6fe53b41e17
  MediaType: application/vnd.docker.distribution.manifest.v2+json
  Platform:  linux/amd64
```

## otter镜像构建命令
1. 本地构建：docker build --no-cache --build-arg "HTTP_PROXY=http://192.168.0.1:7890" --build-arg "HTTPS_PROXY=http://192.168.0.1:7890" -t test:v1 .
2. 多架构构建：docker buildx build -t jiayu98/otter:v0.1 --build-arg "HTTP_PROXY=http://192.168.0.1:7890" --build-arg "HTTPS_PROXY=http://192.168.0.1:7890" --platform linux/arm64,linux/amd64 .