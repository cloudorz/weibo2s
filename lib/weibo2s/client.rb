require 'oauth2'

module WeiboOAuth2
  class Client < OAuth2::Client
 
    def initialize(client_id='', client_secret='', opts={}, &block)
      client_id = WeiboOAuth2::Config.api_key if client_id.empty?
      client_secret = WeiboOAuth2::Config.api_secret if client_secret.empty?
      super
      @site = "https://api.weibo.com/2/"
      @options[:authorize_url] = '/oauth2/authorize'
      @options[:token_url] = '/oauth2/access_token'
    end
    
    def authorize_url(params={})
      params[:client_id] = @id unless params[:client_id]
      params[:response_type] = 'code' unless params[:response_type]
      params[:redirect_uri] = WeiboOAuth2::Config.redirect_uri unless params[:redirect_uri]
      super
    end
    
    def get_token(params, access_token_opts={})
      params = params.merge({:parse => :json})
      access_token_opts = access_token_opts.merge({:header_format => "OAuth2 %s", :param_name => "access_token"})
      super
    end
    
    def get_and_restore_token(params, access_token_opts={})
      @access_token = get_token(params, access_token_opts={})
    end
    
    def get_token_from_hash(hash)
      access_token = hash.delete(:access_token) || hash.delete('access_token')
      opts = {:expires_at => (hash.delete(:expires_at) || hash.delete('expires_at')),
              :header_format => "OAuth2 %s",
              :param_name => "access_token"}

      @access_token = WeiboOAuth2::AccessToken.new(self, access_token, opts)
    end
    
    def authorized?
      !!@access_token
    end

    def method_missing(name, *args)
        name_str = name.to_s
        super unless WeiboOAuth2::Config.apis.include? name_str
        apis = WeiboOAuth2::Config.apis[name_str]

        self.class.class_eval do
            define_method(name) do
                p = "@#{name.to_s}"
                instance_variable_set(p, WeiboOAuth2::Api::V2::Base.new(@access_token, param)) unless instance_variable_get(p) if @access_token
                instance_variable_get(p)
            end
        end

        send(name, apis)
    end

    # respond_to
    def respond_to?(name)
        unless methods.include? name
            name_str = name.to_s
            unless WeiboOAuth2::Config.apis.include? name_str
                return super
            end
        end

        true
    end
    
  end 
end
