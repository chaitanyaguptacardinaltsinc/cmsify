class Cmsify::PaginateAssetsController <  Cmsify::BaseController
  
  def index
    @assets = ::Cmsify::Asset.page(params[:page]).per(30)
  end
  
end
