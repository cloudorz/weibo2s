require 'hashie'
require 'json'
require 'rest_client'
require 'net/http/post/multipart'

module WeiboOAuth2
  module Api
    module V2
      class Base
        extend Forwardable
        
        def_delegators :@access_token, :get, :post, :put, :delete
        
        @@API_VERSION = 2
        
        def initialize(access_token)
          @access_token = access_token
        end
        
        def hashie(response)
          json_body = JSON.parse(response.body)
          if json_body.is_a? Array
            Array.new(json_body.count){|i| Hashie::Mash.new(json_body[i])}
          else
            Hashie::Mash.new json_body
          end
        end
        
        def method_missing(name, *args)
            fst, snd = name.to_s.split('_', 2)
            super unless WeiboOAuth2::Config.apis.include? fst
            api_info = WeiboOAuth2::Config.apis[fst][snd]
            super unless api_info

            method =  api_info['method'].downcase || 'get'
            if api_info['attachment']
                self.class.class_eval do
                    define_method(name) do |params|
                       multipart = self.calss.build_multipart_bodies(params)
                       hashie send(method, api_info['url'], :headers => multipart[:headers], :body => multipart[:body])
                    end
                end
            else
                if api_info['url'].start_with?('https://') or api_info['url'].start_with?('http://')
                    self.class.class_eval do
                        if ['post', 'put'].include? method
                            define_method(name) do
                                hashie RestClient.send(method, api_info['url'], :access_token => @access_token.token)
                            end
                        else
                            define_method(name) do
                                hashie RestClient.send(method, "#{api_info['url']}?access_token=#{@access_token.token}")
                            end
                        end
                    end
                else
                    self.class.class_eval do
                        define_method(name) do |params|
                           hashie send(method, api_info['url'], :params => params)
                        end
                    end
                end
            end

            if args.length > 0
                send(name, args[0])
            else
                send(name)
            end
        end

        # respond_to

        protected
        def self.mime_type(file)
          case
            when file =~ /\.jpg/ then 'image/jpg'
            when file =~ /\.gif$/ then 'image/gif'
            when file =~ /\.png$/ then 'image/png'
            else 'application/octet-stream'
          end
        end
        
        CRLF = "\r\n"
        def self.build_multipart_bodies(parts)
          boundary = Time.now.to_i.to_s(16)
          body = ""
          parts.each do |key, value|
            esc_key = CGI.escape(key.to_s)
            body << "--#{boundary}#{CRLF}"
            if value.respond_to?(:read)
              body << "Content-Disposition: form-data; name=\"#{esc_key}\"; filename=\"#{File.basename(value.path)}\"#{CRLF}"
              body << "Content-Type: #{mime_type(value.path)}#{CRLF*2}"
              body << value.read
            else
              body << "Content-Disposition: form-data; name=\"#{esc_key}\"#{CRLF*2}#{value}"
            end
            body << CRLF
          end
          body << "--#{boundary}--#{CRLF*2}"
          {
            :body => body,
            :headers => {"Content-Type" => "multipart/form-data; boundary=#{boundary}"}
          }
        end
      end
    end
  end
end
