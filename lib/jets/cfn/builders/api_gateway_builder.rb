module Jets::Cfn::Builders
  class ApiGatewayBuilder
    include Interface
    include Jets::AwsServices

    def initialize(options={})
      @options = options
      @template = ActiveSupport::HashWithIndifferentAccess.new(Resources: {})
    end

    # compose is an interface method
    def compose
      add_gateway_routes # "child template": build before add_gateway_rest_api. RestApi logical id and change detection is dependent on it.
      add_gateway_rest_api # changes parent template
      add_custom_domain    # changes parent template
    end

    # template_path is an interface method
    def template_path
      Jets::Naming.api_gateway_template_path
    end

    # do not bother writing a template if routes are empty
    def write
      super unless Jets::Router.routes.empty?
    end

    # If the are routes in config/routes.rb add Gateway API in parent stack
    def add_gateway_rest_api
      rest_api = Jets::Resource::ApiGateway::RestApi.new
      add_resource(rest_api)
      add_outputs(rest_api.outputs)

      deployment = Jets::Resource::ApiGateway::Deployment.new
      outputs = deployment.outputs(true)
      add_output("RestApiUrl", Value: outputs["RestApiUrl"])
    end

    def add_custom_domain
      return unless Jets.custom_domain?
      add_domain_name
      add_route53_dns if Jets.config.domain.route53
    end

    def add_domain_name
      domain_name = Jets::Resource::ApiGateway::DomainName.new
      add_resource(domain_name)
      add_outputs(domain_name.outputs)
    end

    def add_route53_dns
      dns = Jets::Resource::Route53::RecordSet.new
      add_resource(dns)
      add_outputs(dns.outputs)
    end

    # Adds route related Resources and Outputs
    # Delegates to ApiResourcesBuilder
    PAGE_LIMIT = Integer(ENV['JETS_AWS_OUTPUTS_LIMIT'] || 60) # Allow override for testing
    def add_gateway_routes
      # Reject homepage. Otherwise we have 60 - 1 resources on the first page.
      # There's a next call in ApiResources.add_gateway_resources to skip the homepage.
      all_paths = Jets::Router.all_paths.reject { |p| p == '' }
      all_paths.each_slice(PAGE_LIMIT).each_with_index do |paths, i|
        ApiResourcesBuilder.new(@options, paths, i+1).build
      end
    end
  end
end
