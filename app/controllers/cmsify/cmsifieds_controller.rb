class Cmsify::CmsifiedsController < Cmsify::BaseController
  include ::Cmsify::DynamicallyControllable

  def create
    @resource.save
    respond_with(@resource, location: [cmsify, controller_class_collection_symbol])
  end

  def update
    @resource.update(resource_params)
    respond_with(cmsify, :edit, @resource)
  end

  def destroy
    @resource.destroy
    respond_with(cmsify, @resource)
  end
end
