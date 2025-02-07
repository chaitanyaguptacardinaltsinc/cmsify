class Cmsify::ResourcesController < Cmsify::BaseController
  include ::Cmsify::DynamicallyControllable
  include ::Cmsify::DynamicallyAuthorizable
  include ::Cmsify::AssetAttachable

  before_action :add_root_breadcrumb
  helper_method :parent_collection, :has_access_tags?

  def create
    if @resource.save
      successful_response 
    else
      failed_response
    end
  end

  def update
    if @resource.update(resource_params)
      successful_response
    else
      failed_response
    end
  end

  def destroy
    if @resource.destroy
      successful_response
    else
      failed_response
    end
  end

  def sort
    params[:order].each do |key, value|
      controller_class_name.constantize.find(value[:name]).update_attribute(:rank, value[:value])
    end
    head :ok
  end

  private

    def add_root_breadcrumb
      add_breadcrumb "Content", [cmsify, :content]
      add_breadcrumb controller_namespace.pluralize.titleize, [cmsify, controller_namespace_symbol, controller_name.to_sym]
    end

    def failed_response
      respond_with(cmsify, :edit, parent_collection_or_namespace, controller_class_symbol, @resource)
    end

    def has_access_tags?
      Cmsify.config.access_tags.any? && ActiveRecord::Base.connection.data_source_exists?(:taggings)
    end
end
