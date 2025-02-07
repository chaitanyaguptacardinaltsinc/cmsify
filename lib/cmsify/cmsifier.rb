require_dependency 'cmsify/klass/attached'
require_dependency 'cmsify/klass/collection'
require_dependency 'cmsify/klass/item'
require_dependency 'cmsify/klass/collections_controller'
require_dependency 'cmsify/klass/items_controller'

module Cmsify
  class Cmsifier
    def self.cmsify
      Klass::Attached.new({ class_name: :featured_image, parent_class_name: "::Cmsify::BaseAttached" })
      Cmsify.config.content_type_classes.each do |content_type|
        Klass::Collection.new({ module_name: content_type })
        Klass::Item.new({ module_name: content_type, schema: ::Cmsify.config.fields_for_content_type_schema(content_type.to_s.underscore.to_sym) })
        Klass::CollectionsController.new({ module_name: content_type })
        Klass::ItemsController.new({ module_name: content_type })
      end

      ActionView::Base.send :include, ::Cmsify::PublicHelper
    end
  end
end
