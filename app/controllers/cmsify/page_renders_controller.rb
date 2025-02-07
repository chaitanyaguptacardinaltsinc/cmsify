class Cmsify::PageRendersController < Cmsify::RendersController
  include Rails.application.routes.url_helpers

  def show
    path_parts = params[:path].try(:split, '/') || []
    @page = Cmsify::Page.find_by_path("/" + path_parts.join("/"))
    render "templates/#{ @page.template }", layout: get_layout
  end
end
