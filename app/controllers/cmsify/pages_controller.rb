class Cmsify::PagesController < Cmsify::BaseController
  before_action :load_page, only: [ :edit, :update, :destroy ]
  before_action :load_pages
  before_action :load_templates, only: [ :new, :edit, :create, :update ]

  def create
    @page = ::Cmsify::Page.create(page_params)
    respond_with @page, location: -> { [cmsify, :edit, @page] }
  end

  def new
    @page = context.new
  end

  def destroy
    @page.destroy
    respond_with @page
  end

  def update
    @page.update(page_params)
    respond_with @page, location: -> { [cmsify, :edit, @page] }
  end


  private
    def context
      parent_page.try(:children) || Cmsify::Page
    end

    def parent_page
      Cmsify::Page.find_by_id(params[:page_id])
    end

    def load_page
      @page = ::Cmsify::Page.find(params[:id])
    end

    def load_pages
      @pages = ::Cmsify::Page.without_parent.accessible_by(current_ability)
    end

    def cmsify_templates
      build_template_list_for_directory("#{ Cmsify.root }/app/views/templates/")
    end

    def app_templates
      build_template_list_for_directory("#{ Rails.root }/app/views/templates/")
    end

    def build_template_list_for_directory(directory)
      Dir["#{ directory }**/*"].reject { |f| File.directory?(f) }.map do |f|
        f.sub(directory, '')
      end
    rescue Errno::ENOENT => e
      []
    end

    def load_templates
      @templates = (cmsify_templates + app_templates).reject{|entry| entry == "." || entry == ".."}.uniq
    end

    def page_params
      params.require(:page).permit(
        :name,
        :url,
        :slug,
        :description,
        :template,
        :parent_id,
        :state)
    end
end
