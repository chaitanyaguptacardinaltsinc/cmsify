module Cmsify
  class Klass::Item < Klass
    include Cmsify::Schemable

    private
      def class_contents
        content_type_symbol = @module_name.underscore.to_sym

        item_datetime_fields = datetime_fields
        asset_fields = ::Cmsify.config.asset_fields_for_content_type(content_type_symbol)

        asset_fields.each do |asset_field_name, asset_field|
          Klass::Attached.new({ class_name: asset_field_name, parent_class_name: "::Cmsify::BaseAttached" })
        end

        Proc.new do
          asset_fields.each do |asset_field_name, asset_field|
            has_one "attached_#{ asset_field_name }".to_sym, class_name: "::Cmsify::Attached::#{ asset_field_name.to_s.classify }", as: :attachable, inverse_of: :attachable
            has_one asset_field_name, through: "attached_#{ asset_field_name }", source: :asset
            accepts_nested_attributes_for "attached_#{ asset_field_name }", allow_destroy: true, reject_if: proc { |attributes| attributes[:asset_id].blank? }
          end

          item_datetime_fields.each do |asset_field_name, asset_field|
            scope_name = asset_field_name.to_s.split("_").first
            scope scope_name, -> { where("#{ asset_field_name } <= ?", Time.current) }
          end

          class_eval <<-RUBY
            def self.default_allowed_params(configuration = :default)
              super() + Cmsify.config.mass_assignable_fields_for_content_type_configuration(:#{ content_type_symbol }, configuration)
            end
          RUBY
        end
      end
  end
end
