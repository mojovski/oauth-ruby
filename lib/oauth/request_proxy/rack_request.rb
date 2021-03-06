require 'oauth/request_proxy/base'
require 'uri'
require 'rack'

module OAuth::RequestProxy
  class RackRequest < OAuth::RequestProxy::Base
    proxies Rack::Request

    def method
      request.env["rack.methodoverride.original_method"] || request.request_method
    end

    def uri
      request.url
    end

    def parameters
      if options[:clobber_request]
        options[:parameters] || {}
      else
        params = request_params.merge(query_params).merge(header_params)
        params.merge(options[:parameters] || {})
      end
    end

    def signature
      parameters['oauth_signature']
    end

  protected

	def query_params
		res={}
		#puts "query params: #{request.GET.inspect}"
  	begin
      request.GET.each{|k,v| res.merge!({k.to_s=>URI.unescape(v)})}
      return res
    rescue #Exception=>e
      #this happes, if the prameters are a nested hash!
      return request.GET
    end
  end


    def request_params
      if request.content_type and request.content_type.to_s.downcase.start_with?("application/x-www-form-urlencoded")
        request.POST
      else
        {}
      end
    end
  end
end
