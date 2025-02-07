class Cmsify::AssetsController < Cmsify::BaseController
  # load_and_authorize_resource
  respond_to :json, :html

  before_action :build_asset, only: :new
  before_action :load_asset, only: [:show, :destroy]

  def index
    @assets = ::Cmsify::Asset.all.filter_by_scope(params.slice(:searched_term))
    @assets = @assets.page(params[:page]).per(30) if request.format == :html
    @assets = @assets.images if request.format == :json
    respond_with(@assets, each_serializer: ::Cmsify::Tinymce::AssetSerializer, adapter: :attributes)
  end

  def create
    @asset = ::Cmsify::Asset.new(asset_params)
    if @asset.save!
      render json: { asset: Cmsify::AssetSerializer.new(@asset) }
    else
      render json: { error: 'Failed to process' }, status: 422
    end
  end

  def destroy
    @asset.destroy
    respond_with(@asset)
  end

  def asset_params
    # TODO: Make these params more conventional. It will probably require changing `cmsify_assets`
    { attachment: params.require(:file) }
  end

  private
    def build_asset
      @asset = ::Cmsify::Asset.new
    end

    def load_asset
      @asset = ::Cmsify::Asset.find(params[:id])
    end

# if we decide to have check boxes where you can delete multiple assets at once, whcih we should
# def delete_assets
#   Asset.where(id: params[:asset_contents]).destroy_all
#   redirect_to [ :root]
# end

end
