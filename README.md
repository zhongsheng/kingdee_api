# KingdeeApi

一个用于实现金蝶云 API HTTP 请求加签的 Ruby gem。该 gem 提供了便捷的方式来调用金蝶云开放平台的 API，自动处理请求签名和认证。

[金蝶云 API 文档](https://open.jdy.com/#/files/api/detail?index=3&categrayId=3cc8ee9a663e11eda5c84b5d383a2b93&id=adfe4a24712711eda0b307c6992ee459)

## 功能特性

- 🔐 自动处理 API 请求签名
- 🔑 支持环境变量和代码配置两种方式
- 📦 支持 GET、POST 等多种 HTTP 方法
- 📎 支持文件上传功能
- 🚀 简单易用的 API 接口
- 🧩 模块化设计，配置、签名、请求和响应组件彼此解耦

## 安装

### 使用 Bundler

在 `Gemfile` 中添加：

```ruby
gem 'kingdee_api'
```

然后执行：

```bash
bundle install
```

或者直接使用：

```bash
bundle add kingdee_api
```

### 直接安装

如果未使用 Bundler 管理依赖，可以直接安装：

```bash
gem install kingdee_api
```

## 使用

### 配置

#### 方式一：使用环境变量（推荐）

默认使用环境变量进行配置，适合生产环境使用：

```bash
# 设置环境变量
export KINGDEE_CLIENT_ID=327910
export KINGDEE_CLIENT_SECRET=327xxxxxxx910
export KINGDEE_APP_KEY=gsKeflPn
export KINGDEE_APP_SECRET=4bf00ef4c9252e4c727f0e9d762a706d418f5e87
export KINGDEE_DOMAIN=https://tf.jdy.com
```

#### 方式二：初始化时集中配置

在应用启动阶段调用 `KingdeeApi.configure`，可以将配置集中管理，同时保留在任意位置创建客户端的能力：

```ruby
KingdeeApi.configure do |config|
  config.client_id = '327910'
  config.client_secret = '327xxxxxxx910'
  config.app_key = 'gsKeflPn'
  config.app_secret = '4bf00ef4c9252e4c727f0e9d762a706d418f5e87'
  config.domain = 'https://tf.jdy.com'
  config.read_timeout = 20
  config.open_timeout = 5
end

client = KingdeeApi.client # 任何需要的地方都可以拿到配置好的客户端
```

#### 方式三：临时配置某些参数

当少量参数需要按需覆盖时，将它们直接传给 `client` 方法即可：

```ruby
client = KingdeeApi.client(domain: 'https://api.kingdee.com')
```

### 配置参数说明

| 参数 | 说明 | 是否必填 |
|------|------|----------|
| `client_id` | 客户端 ID | 是 |
| `client_secret` | 客户端密钥 | 是 |
| `app_key` | 应用 Key | 是 |
| `app_secret` | 应用密钥 | 是 |
| `domain` | API 域名，如 `https://tf.jdy.com` 或 `https://api.kingdee.com` | 是 |

### API 调用示例

#### GET 请求示例 - 采购申请单列表

用途说明：获取采购申请单列表  
请求方式：GET  
请求地址：`https://api.kingdee.com/jdy/v2/scm/pur_request`

```ruby
# 基本调用
response = KingdeeApi.client.get('jdy/v2/scm/pur_request')

# 带查询参数
response = KingdeeApi.client.get('jdy/v2/scm/pur_request', params: {
  page: 1,
  page_size: 20,
  filter: '...'
})
```

#### POST 请求示例 - 采购申请单保存

用途说明：采购申请单新增及修改。审核、删除等详见通用操作接口  
请求方式：POST  
请求地址：`https://api.kingdee.com/jdy/v2/scm/pur_request`

```ruby
# 基本 POST 请求
response = KingdeeApi.client.post('jdy/v2/scm/pur_request', params: {
  bill_date: '2024-01-01',
  # 其他参数...
})

# 带文件上传的 POST 请求
response = KingdeeApi.client.post('jdy/v2/scm/pur_request', params: {
  bill_date: '2024-01-01',
  # 其他参数...
}) do |request|
  request.attach 'file/path/1'
  request.attach 'file/path/2'
end
```

#### 其他 HTTP 方法

```ruby
# PUT 请求
response = KingdeeApi.client.put('jdy/v2/scm/pur_request', params: { ... })

# DELETE 请求
response = KingdeeApi.client.delete('jdy/v2/scm/pur_request', params: { ... })

# PATCH 请求
response = KingdeeApi.client.patch('jdy/v2/scm/pur_request', params: { ... })
```

### 请求选项与高级用法

- `query:`：强制附加查询字符串（POST/PUT 等也适用）。
- `headers:`：追加自定义请求头。
- `timeout:`：覆盖单次请求的 `open_timeout/read_timeout`。
- `&block`：获取请求构建器并调用 `attach` 方法添加一个或多个文件。也可以通过 `attach(nil, data: '...', filename: 'a.txt')` 传入内存数据。

### 响应处理

```ruby
response = KingdeeApi.client.get('jdy/v2/scm/pur_request')

if response.success?
  response.body # => Hash / Array（自动 JSON 解析）
else
  warn response.error_message || "请求失败: #{response.status}"
end
```

## 开发

### 环境设置

克隆仓库后，运行以下命令安装依赖：

```bash
bin/setup
```

### 运行测试

```bash
rake test
```

### 交互式控制台

可以使用交互式控制台进行实验：

```bash
bin/console
```

### 本地安装

将 gem 安装到本地机器：

```bash
bundle exec rake install
```

### 发布新版本

1. 更新 `lib/kingdee_api/version.rb` 中的版本号
2. 运行发布命令：

```bash
bundle exec rake release
```

这将创建 git 标签、推送提交和标签，并将 `.gem` 文件推送到 [rubygems.org](https://rubygems.org)。

## 常见问题

### Q: 如何获取 API 凭证？

A: 请登录金蝶云开放平台，在应用管理中创建应用并获取相应的 `client_id`、`client_secret`、`app_key` 和 `app_secret`。

### Q: 支持哪些环境？

A: 支持金蝶云的生产环境和测试环境，通过 `domain` 参数配置不同的环境地址。

### Q: 如何处理请求错误？

A: 检查响应状态码和错误信息，根据金蝶云 API 文档中的错误码进行处理。

## Contributing

欢迎提交 Bug 报告和 Pull Request！

项目地址：[https://github.com/zhongsheng/kingdee_api](https://github.com/zhongsheng/kingdee_api)

## License

该 gem 基于 [MIT License](https://opensource.org/licenses/MIT) 开源协议发布。
