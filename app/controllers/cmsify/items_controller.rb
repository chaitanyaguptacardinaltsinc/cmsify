class Cmsify::ItemsController < Cmsify::ResourcesController
  before_action :load_collections
  before_action :set_parent, only: [ :create ]
  before_action :load_content, only: [:index]

  def index
    @items = @items.filter_by_scope(params.slice(:searched_term, :collection)).ordered.includes(:collections)
  end

  private
    def allowed_params
      model_class.default_allowed_params(parent_collection.try(:configuration_type))
    end

    def load_collections
      @collections = collection_model_class.all
    end

    def set_parent
      # Manually set up the polymorphic relationship so the intermediary `collect` is created
      @item.collects.build({ collection_id: parent_collection.id, collectible: @item }) if parent_collection.present?
    end

    def successful_response
      if @resource.destroyed?
        respond_with @resource, location: [cmsify, parent_collection_or_namespace, controller_class_collection_symbol]
      else
        respond_with @resource, location: [cmsify, :edit, parent_collection_or_namespace, controller_class_symbol, id: @resource.id]
      end
    end
end
