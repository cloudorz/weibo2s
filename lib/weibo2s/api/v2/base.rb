require 'hashie'
require 'json'
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
            puts "#{fst}####{snd}####{WeiboOAuth2::Config.apis[rst]}"
            api_info = WeiboOAuth2::Config.apis[fst][snd]
            super unless api_info
            if api_info['attachment']
                define_method(name) do |params|
                   method =  api_info['method'] || 'get'
                   hashie send(method, api_info['url'], :params => params)
                end
            else
                define_method(name) do |params|
                   method =  api_info['method'] || 'get'
                   multipart = build_multipart_bodies(params)
                   hashie send(method, api_info['url'], :headers => multipart[:headers], :body => multipart[:body])
                end
            end
            send(name, args[0])
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
