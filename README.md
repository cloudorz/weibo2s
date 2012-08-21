谢谢 simsicon 的 https://github.com/simsicon/weibo_2

# WeiboOAuth2

Ruby gem weibo's v2 SDK [API](http://open.weibo.com/wiki/API%E6%96%87%E6%A1%A3_V2)

## Requirements
1.  weibo account
2.  weibo app API key
3.  weibo app API secret

## Installation
        
```bash
$ get clone https://github.com/cloudorz/weibo_2.git
$ gem build weibo2s.gemspec
$ gem install weibo2s-0.0.1.gem
```

## Basic Usage

The example written with sinatra in this directory shows how to ask for oauth2 permission, get the token and send status with picture. It should cover basic usage in all ruby apps. You can visit http://weibo-oauth2-example.herokuapp.com/ to see the demo.

update: Sorry, the api key I used for this demo is still in the process of auditing by weibo side, it's not available now for connecting. But you can apply your own api key, clone the example in this directory, then type

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

这个sdk的生成的api方法是根据这个文件动态生成的。当微博的api接口有所变动时，可以更改weibo_api.yml来进行更新

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
    client.statuses.update(params[:status])
    ```
    
    发送带图的微博
        
    ```ruby
    tmpfile = params[:file][:tempfile]
    pic = File.open(tmpfile.path)
    client.statuses.upload(params[:status], pic)
    ```
## Setting up SSL certificates
    手动添加SSL支持
    
    ### Ubuntu

     `openssl version -a`. Append `/certs` to the OPENSSLDIR listed, here it would be `/usr/lib/ssl/certs`.

    ```ruby
        client = WeiboOAuth2::Client.new(YOUR_KEY, YOUR_SECRET, :ssl => {:ca_path => "/usr/lib/ssl/certs"})
        # or as below if you have set WeiboOAuth2::Config.api_key and WeiboOAuth2::Config.api_secret already
        # client = WeiboOAuth2::Client.new('', '', :ssl => {:ca_path => "/usr/lib/ssl/certs"})
    ```

    ### On Heroku, Fedora, CentOS

    ```ruby
        client = WeiboOAuth2::Client.new(YOUR_KEY, YOUR_SECRET, :ssl => {:ca_file => '/usr/lib/ssl/certs/ca-certificates.crt'})
        # or as below if you have set WeiboOAuth2::Config.api_key and WeiboOAuth2::Config.api_secret already
        # client = WeiboOAuth2::Client.new('', '', :ssl => {:ca_file => '/usr/lib/ssl/certs/ca-certificates.crt'})
    ```

     Fedora and CentOS `/etc/pki/tls/certs/ca-bundle.crt` instead, or find your system path with `openssl version -a`.


        
