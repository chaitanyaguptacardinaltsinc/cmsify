module Cmsify
  class Klass::Collection < Klass
    private
      def class_contents
        module_name = @module_name
        Proc.new do
          has_many :collections, class_name: "::Cmsify::#{ module_name }::Collection"
          has_many :items, class_name: "::Cmsify::#{ module_name }::Item", through: :collects, source: :collectible, source_type: "Cmsify::Item"

          enum configuration_type: Cmsify.config.configured_schema[module_name.underscore.to_sym][:configurations].keys
        end
      end
  end
end
