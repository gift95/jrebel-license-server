# 使用更轻量的 JRE 基础镜像替代 JDK 镜像，减少镜像体积
FROM openjdk:8-jre-alpine
WORKDIR /app

# 安装可能需要的额外工具
# alpine 使用 apk 包管理器，而非 apt-get
RUN apk update && apk add --no-cache \
    git

# 先复制pom.xml尝试缓存依赖
COPY pom.xml .
# 使用更可靠的依赖下载方式
RUN mvn dependency:resolve-plugins dependency:resolve -e


# 添加维护者信息
#LABEL maintainer="github.com/wyx176"

# 复制所有项目文件
COPY . .

# 构建项目
RUN mvn clean package -DskipTests -e

# 创建应用目录
WORKDIR /app

# 由于不存在 build 阶段，直接从当前上下文复制构建产物
COPY target/JrebelLicenseServer.jar JrebelLicenseServer.jar

# 设置时区
ENV TZ=Asia/Shanghai
RUN ln -sf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# 设置环境变量，指定端口号
ENV PORT=9009

# 暴露端口
EXPOSE 9009

# 修正 JAR 包名称与实际一致
CMD ["java", "-jar", "JrebelLicenseServer.jar", "-p", "${PORT}"]
