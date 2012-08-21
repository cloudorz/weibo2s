
谢谢 simsicon 的 https://github.com/simsicon/weibo_2

这个sdk请求weibo的api的方法是根据weibo_api.yml动态生成的。当微博的api接口有所变动时，可以更改weibo_api.yml来进行更新

# WeiboOAuth2

Ruby gem weibo's v2 SDK [API](http://open.weibo.com/wiki/API%E6%96%87%E6%A1%A3_V2)

## 安装
        
```bash
$ get clone https://github.com/cloudorz/weibo_2.git
$ gem build weibo2s.gemspec
$ gem install weibo2s-0.0.1.gem
```

## 使用
具体是用看 example, 请修改congig/weibo.yml中的api_key和api_secret

配置 api_key 和 api_secret

1. 

可以将weibo.yml放在你项目目录的config/weibo.yml 
详见 weibo.yml.example

2.
```ruby
WeiboOAuth2::Config.api_key = YOUR_KEY
WeiboOAuth2::Config.api_secret = YOUR_SECRET
WeiboOAuth2::Config.redirect_uri = YOUR_CALLBACK_URL   
```
配置微博api接口的yml
详见weibo_api.yml.example
config/weibo_api.yml

1.  如何获取token

    设置  YOUR_CALLBACK_URL as 'http://127.0.0.1/callback'

    
    ```ruby
    client = WeiboOAuth2::Client.new  
    ```
    
    生成重定向URL
    
    ```ruby
    client.authorize_url
    ```
    
    在回调方法中添加下面这样代码
    
    ```ruby
    client.auth_code.get_token(params[:code])
    ```
    
    这样就获得到token
    
2.  使用api发送微博
    
    发送普通微博
        
    ```ruby
    client.statuses.update({:status => "test"})
    ```
    
    发送带图的微博
        
    ```ruby
    tmpfile = params[:file][:tempfile]
    pic = File.open(tmpfile.path)
    client.statuses.upload({:status => "分享图片", :pic => pic})
    ```
## 设置SSL
    
    ### Ubuntu

     `openssl version -a`.中OPENSSLDIR的路径追加 `/certs` 例如: `/usr/lib/ssl/certs`.

    ```ruby
        client = WeiboOAuth2::Client.new(YOUR_KEY, YOUR_SECRET, :ssl => {:ca_path => "/usr/lib/ssl/certs"})
        # 下面是你在WeiboOAuth2::Config中设置过api_key, api_secret
        # client = WeiboOAuth2::Client.new('', '', :ssl => {:ca_path => "/usr/lib/ssl/certs"})
    ```

    ### 在 Heroku, Fedora, CentOS

    ```ruby
        client = WeiboOAuth2::Client.new(YOUR_KEY, YOUR_SECRET, :ssl => {:ca_file => '/usr/lib/ssl/certs/ca-certificates.crt'})
        # 下面是你在WeiboOAuth2::Config中设置过api_key, api_secret
        # client = WeiboOAuth2::Client.new('', '', :ssl => {:ca_file => '/usr/lib/ssl/certs/ca-certificates.crt'})
    ```
