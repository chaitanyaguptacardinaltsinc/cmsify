class Cmsify::BaseController < Cmsify::AuthenticatedController
  layout 'cmsify/base'
  responders :flash, :http_cache
  respond_to :html
  protect_from_forgery with: :exception
  def current_ability
    defined?(super) ? super : nil
  end

  before_action :store_front_end_location

  def store_front_end_location
    return unless request.try(:referrer).present?
    parsed_referrer = URI.parse(request.referrer)
    referrer_root_path = parsed_referrer.path.split('/')[1]
    current_root_path = request.original_fullpath.split('/')[1]

    return unless request.host == parsed_referrer.host
    return unless referrer_root_path != current_root_path

    session[:cmsify_return_url] = request.referrer
  end
  private
    def load_content
      @content_types = Cmsify.config.content_types.sort
      if ActiveRecord::Base.connection.data_source_exists? ::Cmsify::Collection.table_name
        @collection_groups = ::Cmsify::Collection.accessible_by(current_ability).order(name: :asc).without_parent
          .includes(:items, children: [:items, children: [:items, children: [:items, children: :items]]])
          .group_by {|collection| collection.type.deconstantize.demodulize.underscore.to_sym }
      else
        flash[:error] = "You need to run the cmsify database migrations: `rails cmsify:install:migrations` and `rake db:migrate`"
      end
    end
end
