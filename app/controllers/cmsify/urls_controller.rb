class Cmsify::UrlsController < Cmsify::BaseController
  before_action :load_url, only: [ :edit, :update, :destroy ]

  def index
    @urls = ::Cmsify::Url.accessible_by(current_ability)
  end

  def create
    @url = ::Cmsify::Url.create(url_params)
    successful_response
  end

  def new
    @url = ::Cmsify::Url.new
  end

  def destroy
    if @url.destroy
      successful_response
    else
      failed_response
    end
  end

  def update
    if @url.update(url_params)
      successful_response
    else
      failed_response
    end
  end


  private
    def successful_response
      respond_with @url, location: [cmsify, :urls]
    end

    def failed_response
      respond_with @url, location: [cmsify, :edit, @url]
    end

    def load_url
      @url = ::Cmsify::Url.find(params[:id])
    end

    def url_params
      params.require(:url).permit(
        :url,
        :title,
        :description,
        :state)
    end
end
