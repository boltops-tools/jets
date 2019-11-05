require 'cfn/status'

module Jets::Cfn
  class Status < Cfn::Status
    def initialize(options={})
      @stack_name = Jets::Naming.parent_stack_name
      super(@stack_name, options)
    end
  end
end
