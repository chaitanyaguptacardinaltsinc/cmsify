# lib/cmsify/klass.rb
module Cmsify
  class Klass
    attr_reader :module_name, :class_name, :parent_class, :module_path_name, :schema
    def initialize(attributes = {})
      # TODO: This initialization is starting to smell funny. Need to refactor
      super()
      if attributes[:module_name].present?
        @module_name = attributes[:module_name].to_s.classify
        @class_name = self.class.name.demodulize
        @parent_class = "::Cmsify::#{ @class_name }".constantize
      elsif attributes[:class_name].present?
        @module_name = self.class.name.demodulize
        @class_name = attributes[:class_name].to_s.classify
        @parent_class = (attributes[:parent_class_name] || "::Cmsify::#{ @module_name }").constantize
      end
      @module_path_name = attributes[:module_path_name] || "::Cmsify::#{ @module_name }"
      @schema = attributes[:schema]

      unless Object.const_defined?(@module_path_name)
        Cmsify.const_set(@module_name, Module.new)
      end

      silence_warnings do
        @module_path_name.constantize.const_set(@class_name, Class.new(@parent_class, &class_contents))
      end
    end

    private
      def class_contents
      end
  end
end
