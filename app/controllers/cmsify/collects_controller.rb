class Cmsify::CollectsController < Cmsify::BaseController
  before_action :load_collect

  def destroy
    @collect.destroy
    respond_with @collect, location: [:edit, @collect.collection]
  end

  private
    def load_collect
      @collect = ::Cmsify::Collect.accessible_by(current_ability).find(params[:id])
    end
end
