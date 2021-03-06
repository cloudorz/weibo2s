require "yaml"

require "weibo2s/version"
require "weibo2s/config"
require "weibo2s/base"
require "weibo2s/client"
require "weibo2s/access_token"
require "weibo2s/api/v2/base"
require "weibo2s/strategy/auth_code"

if File.exists?('config/weibo.yml')
  weibo_oauth = YAML.load_file('config/weibo.yml')[ENV["RAILS_ENV"] || ENV["RACK_ENV"] || "development"]
  WeiboOAuth2::Config.api_key = weibo_oauth["api_key"]
  WeiboOAuth2::Config.api_secret = weibo_oauth["api_secret"]
else
  puts "\n\n=========================================================\n\n" +
       "  You haven't made a config/weibo.yml file.\n\n  You should.  \n\n  The weibo gem will work much better if you do\n\n" +
       "  Please set Weibo::Config.api_key and \n  Weibo::Config.api_secret\n  somewhere in your initialization process\n\n" +
       "=========================================================\n\n"
end

if File.exists?('config/weibo_api.yml')
    WeiboOAuth2::Config.apis = YAML.load_file('config/weibo_api.yml')
else
    puts "No apis YAML file can't work.\n You should make a config/weibo_api.yml file.\nLike: https://github.com/cloudorz/weibo2s/blob/master/weibo_api.yml.example"
end
