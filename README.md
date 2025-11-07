# KingdeeApi

实现金蝶云api的http请求加签.
[https://open.jdy.com/#/files/api/detail?index=3&categrayId=3cc8ee9a663e11eda5c84b5d383a2b93&id=adfe4a24712711eda0b307c6992ee459](金蝶云api文档)

## Installation

```bash
bundle add UPDATE_WITH_YOUR_GEM_NAME_IMMEDIATELY_AFTER_RELEASE_TO_RUBYGEMS_ORG
```

If bundler is not being used to manage dependencies, install the gem by executing:

```bash
gem install UPDATE_WITH_YOUR_GEM_NAME_IMMEDIATELY_AFTER_RELEASE_TO_RUBYGEMS_ORG
```

## Usage

默认使用环境变量

``` bash
# load env 
export KINGDEE_CLIENT_ID=327910
export KINGDEE_CLIENT_SECRET=327xxxxxxx910
export KINGDEE_APP_KEY=gsKeflPn
export KINGDEE_APP_SECRET=4bf00ef4c9252e4c727f0e9d762a706d418f5e87
export KINGDEE_DOMAIN=https://tf.jdy.com
```

or

``` ruby
KingdeeApi.client(   
   client_id: '327910',
   client_secret: '327xxxxxxx910',
   app_key: 'gsKeflPn',
   app_secret: '4bf00ef4c9252e4c727f0e9d762a706d418f5e87',
   domain: 'https://tf.jdy.com'
)

```

### 示例- 采购申请单列表
用途说明：采购申请单列表
请求方式：GET
请求地址：https://api.kingdee.com/jdy/v2/scm/pur_request

``` ruby
KingdeeApi.client.get('jdy/v2/scm/pur_request')
```

### 采购申请单保存
用途说明：采购申请单新增及修改。审核、删除等详见通用操作接口
请求方式：POST
请求地址：https://api.kingdee.com/jdy/v2/scm/pur_request


``` ruby
KingdeeApi.client.post('jdy/v2/scm/pur_request', params: {
   bill_date: 'xxx',
   ...
}) do |request|
   request.attach 'file/path/1'
   request.attach 'file/path/2'
end
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/zhongsheng/kingdee_api.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
