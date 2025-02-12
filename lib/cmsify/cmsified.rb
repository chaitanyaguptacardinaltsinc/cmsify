require_relative 'concerns/cmsify/schemable'

module Cmsify
  module Cmsified
    include Cmsify::Schemable

    def cmsified?
      false
    end

    def cmsify(options)
      @schema = options[:schema]
      cmsified_class_name = self.name.underscore.to_sym
      Cmsify.config.cmsified[cmsified_class_name] = @schema unless Cmsify.config.cmsified.keys.include?(cmsified_class_name)

      class_eval do
        if required_fields.any?
          class_eval <<-RUBY
            validates_presence_of #{ required_fields }
          RUBY
        end

        def self.cmsified?
          true
        end
      end

      Klass::CmsifiedsController.new({ class_name: self.name.pluralize + 'Controller', module_path_name: "::Cmsify", schema: @schema })
    end
  end
end
