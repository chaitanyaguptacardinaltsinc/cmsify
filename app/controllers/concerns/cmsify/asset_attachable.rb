module Cmsify::AssetAttachable
  extend ActiveSupport::Concern

  included do
    before_action :load_assets
  end

  private
    def load_assets
      @assets = ::Cmsify::Asset.accessible_by(current_ability)
      # HACK: Need to ensure at least one asset exists in order for the HTML template for the
      # inserted elements to render in the DOM
      @assets = [::Cmsify::Asset.new()] if @assets.empty?
    end
end
