class Cmsify::CollectionsController < Cmsify::ResourcesController
  before_action :load_items
  before_action :handle_item_ids, only: [:update]
  before_action :load_content

  private
    def load_items
      @items = item_model_class.all
    end

    def handle_item_ids
      # TODO: Right now the list of item_ids is being manually processed due to a bug in
      # `composite-primary-keys`. (See: https://github.com/composite-primary-keys/composite_primary_keys/issues/379)
      # The bug is triggered when `source` is required to determine class name of the polymorphic
      # relationship. Once that bug is fixed this should be stripped out and replaced with the
      # built-in rails solution for `collection_singular_ids`.
      remove_items
      params[model_class_params_key][:item_ids].each do |item_id|
        if !item_id.empty? && !@collection.item_ids.include?(item_id.to_i)
          @collection.items << @items.find(item_id)
        end
      end
    end

    def remove_items
      # TODO more stuff to do with composite-primary-keys need to remove the items that are
      # to be delete without destroying every collect, needs to be improved to not run in O(n^2)
      @collection.item_ids.each do |item_id|
        unless params[model_class_params_key][:item_ids].include? item_id.to_s
          params[model_class_params_key][:collects_attributes].each do |index, collect|
            if (collect["collectible_id"] == item_id.to_s)
              collect[:_destroy] = true
            end
          end
        end
      end
    end

    def resource_params
      super.merge({ type: model_class })
    end

    def successful_response
      if @resource.destroyed?
        respond_with @resource, location: @resource.has_parent? ? [cmsify, :edit, @resource.collection] : [cmsify, controller_namespace_symbol, :items]
      else
        respond_with @resource, location: [cmsify, :edit, @resource]
      end
    end
end
