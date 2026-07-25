# 智能题库网站

一个前后端分离的题库管理与刷题系统，覆盖管理员、授权管理员和考生三类身份，支持多题库、多租户、AI 解答和考试任务分发。

## 技术栈

- 后端：Java 8、Spring Boot 2.7、MyBatis-Plus、MySQL、JWT、BCrypt
- 前端：Vue2、Vue Router（懒加载）、Vuex、Axios、Element UI
- 数据库：MySQL 5.7+/8.0
- AI：DeepSeek（题目生成、AI 组卷、AI 解答、成绩分析、AI 对话）
- 数据库迁移：Flyway

## 目录

- `backend/`：Spring Boot REST API
- `frontend/`：Vue2 + Element UI 前端
- `database/schema.sql`：MySQL 建表和演示数据（全量，新环境只需执行此文件）
- `database/upgrade-*.sql`：增量升级脚本（已有库按日期顺序执行）
- `database/migration/`：Flyway 迁移脚本（V2 及以后）

## 角色与账号策略

系统不再开放公开注册，所有账号由后台 `ADMIN` 统一创建。

| 角色 | 编码 | 说明 |
| --- | --- | --- |
| 超级管理员 | `ADMIN` | 系统最高权限，可管理全部题库、用户、租户和系统配置 |
| 授权管理员 | `MANAGER` | 可维护被授权的题库数据，用户管理只读 |
| 教师 | `TEACHER` | 可管理题库、试卷和考试任务，可查看学生成绩 |
| 审核员 | `REVIEWER` | 负责题目审核流程，可批准或驳回待审核题目 |
| 考生 | `STUDENT` | 刷题、考试、错题本、智能推荐、成绩分析 |

## 启动

### 1. 创建数据库并导入数据

```bash
mysql -u root -p --default-character-set=utf8mb4 < database/schema.sql
```

> 新环境只需执行 `schema.sql`，所有升级脚本已合并到全量建库脚本中。
> 已有库按日期顺序执行 `database/upgrade-*.sql`。

### 2. 启动后端

```bash
cd backend
mvn spring-boot:run
```

后端默认运行在 `http://localhost:8080`。

### 3. 启动前端

```bash
cd frontend
npm install
npm run serve
```

前端默认运行在 `http://localhost:8081`。

> 前端开发服务器通过 `vue.config.js` 中的 proxy 将 `/api` 请求代理到后端 `http://localhost:8080`。
> 如果后端端口有变动，请同步修改 `vue.config.js` 中的 `target`。

### 4. 访问系统

浏览器打开 `http://localhost:8081`。

## 演示账号

| 角色 | 用户名 | 密码 |
| --- | --- | --- |
| 超级管理员 | `admin` | `123456` |
| 授权管理员 | `manager` | `123456` |
| 考生 | `student` | `123456` |

## 环境变量配置

后端支持以下环境变量覆盖默认配置：

```bash
DB_URL=jdbc:mysql://localhost:3306/question_bank?useUnicode=true&characterEncoding=utf8&serverTimezone=Asia/Shanghai
DB_USERNAME=root
DB_PASSWORD=你的数据库密码
JWT_SECRET=你的JWT密钥
JWT_EXPIRE_HOURS=24
TOKEN_ENCRYPTION_KEY=你的Token加密密钥
DEEPSEEK_API_KEY=你的DeepSeek密钥
DEEPSEEK_BASE_URL=https://api.deepseek.com
DEEPSEEK_MODEL=deepseek-v4-pro
```

也可使用 jar 同级的 `application-local.yml` 存放本地密钥，通过 `--spring.profiles.active=local` 启用。该文件已被 `.gitignore` 忽略。

## 已实现功能

### 管理端

- 数据看板（统计概览 + Excel 导出）
- 题库管理（多题库、授权、多租户）
- 知识点管理（树形结构、分页查询）
- 题目管理（六种题型、批量导入、AI 生成题目）
- 试卷管理（自定义组卷、AI 智能组卷、题目拖拽排序）
- 考试任务分发（定时考试、试卷快照、成绩报表、AI 分析）
- 用户管理（增删改查、重置密码、题库授权）
- 角色管理（菜单树授权、功能权限）
- 菜单管理（管理端 + 用户端统一配置）
- 公告管理（富文本公告）
- AI 对话（思考过程 + 正文双流输出）
- 操作日志（自动记录 API 调用）

### 考生端

- 学习首页（答题统计、今日建议）
- 章节练习（按知识点、背题模式、题目评论）
- 模拟考试（一题一页、题目总览、证书下载）
- 考试任务中心（待考/进行中/已完成、倒计时、草稿保存）
- 错题本（错题列表、历史记录、错题练习闭环）
- 智能推荐（基于错题知识点的规则推荐）
- 成绩分析（排名、历史对比、成绩趋势图、AI 分析）
- 热点公告

### 安全与工程

- JWT 登录态 + 后端接口权限拦截
- 前端路由权限控制
- BCrypt 密码加密
- 接口限流
- HTML 内容基础清洗
- 个人 DeepSeek Token AES-GCM 加密存储
- Flyway 数据库版本管理
- 前端路由懒加载
- 基础接口测试

## 题库导入格式

题目管理页可下载 Excel 模板，推荐字段如下：

```text
题库,知识点,试卷,题型,难度,分值,题干,A,B,C,D,E,正确答案,解析
```

- 题型：`单选`、`多选`、`判断`、`填空`、`计算`、`作图`、`主观`
- 难度：`简单`、`中等`、`困难`，也支持 `EASY`、`MEDIUM`、`HARD`
- 多选答案使用英文逗号，例如 `A,C`
- 判断题答案使用 `正确` 或 `错误`
- 填空题支持多个可接受答案，使用 `||` 分隔
- 计算题填写最终标准结果
- 作图题/主观题填写参考说明，考生作答后进入人工核对
- 导入时如果知识点不存在，系统会自动创建
- 题干和解析支持 HTML 内容

## 生产部署

### 前端构建

```bash
cd frontend
npm run build
```

产物在 `frontend/dist/`，可用 Nginx 部署。

### 后端打包

```bash
cd backend
mvn -DskipTests package
```

产物在 `backend/target/question-bank-0.0.1-SNAPSHOT.jar`。

### Nginx 配置

生产环境使用 Nginx 反向代理时，需要允许题干、答案和解析中的图片数据通过：

```nginx
server {
    client_max_body_size 20m;

    location /api/ {
        proxy_pass http://后端地址:8080;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }

    location / {
        root /path/to/frontend/dist;
        try_files $uri $uri/ /index.html;
    }
}
```

修改后执行 `nginx -t` 检查配置，并重新加载 Nginx。
