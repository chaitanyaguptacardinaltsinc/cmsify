module Cmsify::DynamicallyAuthorizable
  extend ActiveSupport::Concern

  included do
    before_action :authorize_resource

    helper_method :controller_namespace_path, :controller_namespace, :controller_namespace_symbol,
      :parent_collection_or_namespace, :resource_name, :children_or_collections
  end

  private
    def controller_namespace_path
      # Extract content type from rquest path (eg: root/content/[news, resources, etc.])
      request.path.split('/').fourth
    end

    def controller_namespace
      controller_namespace_path.classify
    end

    def controller_namespace_symbol
      controller_namespace.underscore.to_sym
    end

    def parent_collection_or_namespace
      @parent_collection.present? ? @parent_collection : controller_namespace_symbol
    end

    def children_or_collections
      @parent_collection.present? ? :children : :collections
    end

    def controller_namespace_module
      "::Cmsify::#{ controller_namespace }::"
    end

    def collection_model_class
      "#{ controller_namespace_module }Collection".constantize
    end

    def item_model_class
      "#{ controller_namespace_module }Item".constantize
    end

    def model_class_params_key
      "#{ model_class.to_s.deconstantize.demodulize }::#{ model_class.to_s.demodulize }".underscore.parameterize.underscore.to_sym
    end

    def allowed_params
      model_class.default_allowed_params
    end

    def authorize_resource
      # Implement this when we add authentication to the gem
      # authorize!(params[:action].to_sym, get_resource || model_class)
    end

    def get_resource
      instance_variable_get("@#{ resource_name }")
    end
end
