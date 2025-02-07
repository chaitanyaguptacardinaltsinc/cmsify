module Cmsify::DynamicallyControllable
  extend ActiveSupport::Concern

  included do
    before_action :new_resource, only: [ :new ]
    before_action :build_resource, only: [ :create ]
    before_action :load_resource, except: [ :index, :new, :create ]
    before_action :find_collection, except: :destroy

    helper_method :parent_collection, :controller_class_name, :controller_class_symbol,
      :controller_class_collection_symbol
  end

  private
    def controller_namespace_module
      "::"
    end

    def controller_class_name
      controller_name.classify
    end

    def controller_class_symbol
      controller_class_name.underscore.to_sym
    end

    def controller_class_collection_symbol
      controller_class_symbol.to_s.pluralize.to_sym
    end

    def parent_collection
      if params[:collection_id]
        @parent_collection ||= Cmsify::Collection.accessible_by(current_ability).find(params[:collection_id])
      end
    end

    def model_class
      "#{ controller_namespace_module + controller_class_name }".constantize
    end

    def model_context
      parent_collection.present? ? parent_collection.send(resource_name.pluralize) : model_class
    end

    def resource_name
      controller_name.underscore.singularize
    end

    def new_resource
      set_resource model_context.new
    end

    def build_resource
      set_resource model_context.new(resource_params)
    end

    def load_resource
      resources = model_context.all
      resources = resources.accessible_by(current_ability) if resources.respond_to?(:accessible_by)
      set_resource resources.find(params[:id])
    end

    def set_resource(value)
      if value.respond_to?(:configuration)
        value.assign_attributes({ configuration: parent_collection.try(:configuration_type) })
      end
      @resource = instance_variable_set("@#{ resource_name }", value)
    end

    def find_collection
      collection = model_context.all
      collection = collection.accessible_by(current_ability) if collection.respond_to?(:accessible_by)
      collection = collection.includes(:collections) if collection.respond_to?(:collections)
      set_collection collection
    end

    def set_collection(value)
      @resources = instance_variable_set("@#{ resource_name.pluralize }", value)
    end

    def model_class_params_key
      controller_class_symbol
    end

    def resource_params
      if params[model_class_params_key][:password].try(:blank?)
        params[model_class_params_key].delete(:password)
        params[model_class_params_key].delete(:password_confirmation)
      end
      params.require(model_class_params_key).permit(allowed_params)
    end

    def allowed_params
      []
    end
end
