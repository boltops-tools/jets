# frozen_string_literal: true

module Jets
  module SpecHelpers
    class Request
      attr_accessor :method, :path, :headers, :params
      def initialize(method, path, headers={}, params={})
        @method, @path, @headers, @params = method, path, headers, params
      end

      def event
        json = {}
        id_params = path.scan(%r{:([^/]+)}).flatten
        expanded_path = path.dup
        path_parameters = {}

        id_params.each do |id_param|
          raise "missing param: :#{id_param}" unless params.path_params.include? id_param.to_sym

          path_param_value = params.path_params[id_param.to_sym]
          raise "Path param :#{id_param} value cannot be blank" if path_param_value.blank?

          expanded_path.gsub!(":#{id_param}", path_param_value.to_s)
          path_parameters.deep_merge!(id_param => path_param_value.to_s)
        end

        json['resource'] = path
        json['path'] = expanded_path
        json['httpMethod'] = method.to_s.upcase
        json['pathParameters'] = path_parameters
        json['headers'] = (headers || {}).stringify_keys

        if method != :get
          json['headers']['Content-Type'] = 'application/x-www-form-urlencoded'
          body = Rack::Multipart.build_multipart(params.body_params)

          if body
            json['headers']['Content-Length'] ||= body.length.to_s
            json['headers']['Content-Type'] = "multipart/form-data; boundary=#{Rack::Multipart::MULTIPART_BOUNDARY}"
          else
            body = Rack::Utils.build_nested_query(params.body_params)
          end

          json['body'] = Base64.encode64(body)
          json['isBase64Encoded'] = true
        end

        params.query_params.each do |key, value|
          json['queryStringParameters'] ||= {}
          json['queryStringParameters'][key.to_s] = value.to_s
        end

        json
      end

      def find_route!
        path = self.path
        path = path[0..-2] if path.end_with? '/'
        path = path[1..-1] if path.start_with? '/'

        route = Jets::Router.routes.find { |r| r.path == path && r.method == method.to_s.upcase }
        raise "Route not found: #{method.to_s.upcase} #{path}" if route.blank?

        route
      end

      def dispatch!
        route = find_route!
        controller = Object.const_get(route.controller_name).new(event, {}, route.action_name)
        response = controller.dispatch!

        if !response.is_a?(Array) || response.size != 3
          raise "Expected response to be an array of size 3. Are you rendering correctly?"
        end

        Response.new(response[0].to_i, response[2].read)
      end
    end
  end
end
