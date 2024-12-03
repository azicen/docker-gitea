# docker-gitea

一个基于 `debian` 构建的 `gitea` 容器。

## 使用

### 通过 docker-compose 部署

```yaml
version: "3"

services:
  gitea:
    image: ghcr.io/azicen/gitea:latest
    container_name: gitea
    hostname: gitea
    environment:
      TZ: Asia/Shanghai
      PUID: 1000
      PGID: 1000

      DOMAIN: gitea.example.com
      SSH_DOMAIN: gitea.example.com
      SSH_PORT: 22
      SSH_LISTEN_PORT: 2222
      HTTP_PORT: 3000
      ROOT_URL: https://gitea.example.com
      LFS_START_SERVER: true

      DB_TYPE: postgres
      DB_HOST: db:5432
      DB_NAME: gitea
      DB_USER: root
      DB_PASSWD:

      INSTALL_LOCK: false
      SECRET_KEY:

      DISABLE_REGISTRATION: false
      REQUIRE_SIGNIN_VIEW: false

    restart: always
    volumes:
      - ./custom:/config/custom
      - ./data:/config/data
      - ./tmp:/config/tmp
    ports:
      - "3000:3000"
      - "2222:2222"

```

## 环境变量

| 变量名称             | 默认值          | 描述                                                        |
| -------------------- | --------------- | ----------------------------------------------------------- |
| APP_NAME             | Gitea on debian | 应用程序名称，在页面标题中使用。                            |
| RUN_MODE             | prod            | 应用程序运行模式，会影响性能和调试。"dev"，"prod"或"test"。 |
| DOMAIN               | localhost       | 此服务器的域名，用于 Gitea UI 中显示的 http 克隆 URL。      |
| SSH_DOMAIN           | localhost       | 此服务器的域名，用于 Gitea UI 中显示的 ssh 克隆 URL。       |
| SSH_PORT             | 2222            | 克隆 URL 中显示的 SSH 端口。                                |
| SSH_LISTEN_PORT      | $SSH_PORT       | 内置 SSH 服务器的端口。                                     |
| DISABLE_SSH          | false           | 禁用 SSH 功能。                                             |
| HTTP_PORT            | 3000            | HTTP 监听端口。                                             |
| ROOT_URL             |                 | 覆盖自动生成的公共 URL。                                    |
| LFS_START_SERVER     | false           | 启用 git-lfs 支持。                                         |
| DB_TYPE              | sqlite3         | 正在使用的数据库类型 [mysql，postgres，mssql，sqlite3]。    |
| DB_HOST              | localhost:3306  | 数据库主机地址和端口。                                      |
| DB_NAME              | gitea           | 数据库名称。                                                |
| DB_USER              | root            | 数据库用户名。                                              |
| DB_PASSWD            |                 | 数据库用户密码。                                            |
| INSTALL_LOCK         | false           | 禁止访问安装页面。                                          |
| SECRET_KEY           | ""              | 全局密钥。这应该更改。                                      |
| DISABLE_REGISTRATION | false           | 禁用注册，之后只有管理员才能为用户创建帐户。                |
| REQUIRE_SIGNIN_VIEW  | false           | 启用此选项可强制用户登录以查看任何页面。                    |

更多环境变量通过 `GITEA__SECTION_NAME__KEY_NAME` 形式替换 `app.ini` 设置。
