# 使用多阶段构建
# 阶段1：构建项目
FROM maven:3.6.3-jdk-8-alpine AS builder
WORKDIR /build

# 先复制pom.xml并下载依赖（利用Docker缓存）
COPY pom.xml .
RUN mvn dependency:resolve-plugins dependency:resolve -e

# 复制所有项目文件并构建
COPY . .
RUN mvn clean package -DskipTests -e

# 阶段2：创建运行环境
FROM openjdk:8-jre-alpine
WORKDIR /app

# 安装可能需要的额外工具
RUN apk update && apk add --no-cache \n    git

# 从构建阶段复制JAR文件
COPY --from=builder /build/target/JrebelLicenseServer.jar JrebelLicenseServer.jar

# 设置时区
ENV TZ=Asia/Shanghai
RUN ln -sf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# 设置环境变量，指定端口号
ENV PORT=9009

# 暴露端口
EXPOSE 9009

# 运行应用
CMD ["java", "-jar", "JrebelLicenseServer.jar", "-p", "${PORT}"]
