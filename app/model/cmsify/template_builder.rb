class Cmsify::TemplateBuilder
  include ActionView::Context
  include ActionView::Helpers::CaptureHelper
  include ActionView::Helpers::TextHelper

  def self.get_content_items_for_collection(collection, current_user, current_ability, is_admin = false, params = {})
    content_items = accessible_results(collection.items, current_ability, is_admin)
    if collection.apply_access_rules? && defined?(current_user) && current_user.present?
      content_items = content_items.access_tagged_for(current_user)
    end
    content_items = content_items.filter_by_scope(params.slice :searched_term) if params.try(:[], :searched_term).try(:present?)
    return content_items
  end

  def self.accessible_results(results, current_ability, is_admin)
    defined?(current_ability) ? results.accessible_by(current_ability) : (is_admin ? results : results.active)
  end

  def initialize(collection, user, ability, is_admin, &block)
    @collection = collection
    @user = user
    @ability = ability
    @is_admin = is_admin
    @block = block
  end

  def object
    @collection
  end

  def template_for(type, options = {}, &block)
    includes = [:collections]
    if type == :collections
      includes << :items
    end
    objects = @collection.send(type).accessible_by(@ability).includes(includes)
    case type
    when :items
      objects = Cmsify::TemplateBuilder.get_content_items_for_collection(@collection, @user, @ability, @is_admin, options[:params])
    when :collections
      objects = objects.with_accessible_descendant_items_for(@user, @ability)
    end
    output = objects.map { |object| yield object }.join("")
    output = output_or_default(output, options.try(:[], :default) || "", &block)
  end

  def cmsify_content_for collection
    @block.call Cmsify::TemplateBuilder.new(collection, @ability, @block)
  end

  private
    # TODO: Find a way to combine this method with the similar one inside PublicHelper. To work
    # around an issue with nesting capture statements, this method does direct calls to yield
    # instead of using capture like the one in PublicHelper.
    def output_or_default(output, default_content = "", &block)
      if output.blank?
        output = case default_content.class.name.demodulize.underscore.to_sym
          when :safe_buffer, :string
            return default_content
          when :proc
            default_content.call
          else
            yield RecursiveOpenStruct.new(default_content)
          end
      end
      return nil
    end
end
