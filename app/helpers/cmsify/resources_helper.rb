module Cmsify
  module ResourcesHelper
    def breadcrumb_links(object, index = 0)
      return_links = [object.new_record? ? ["New #{ object.class.name.demodulize.titleize }"] : [object.name, [cmsify, :edit,  object]]]
      if parent_collection.present? && index == 0
        link_to_add = parent_collection
      elsif object.try(:collection).present?
        link_to_add = object.collection
      end
      return_links += breadcrumb_links(link_to_add, index + 1) if link_to_add.present?
      return return_links
    end

    def add_collection_breadcrumbs(collection)
      breadcrumb_links(collection).reverse.each do |breadcrumb|
        add_breadcrumb *breadcrumb
      end
    end

    def should_show_permissions_for_item?(item)
      if parent_collection.present? && has_access_tags?
        parent_collection.apply_access_rules?
      else
        item.collections.none? || item.collections.where({ apply_access_rules: true }).any?
      end
    end

    def modal_target(index)
      %Q(.js-nested-resource[data-model-name="#{model_name}"][data-index="#{index}"] .uk-modal)
    end

    def collect_remove_button(collect)
      link_to [cmsify, collect], method: :delete, class: "uk-flex uk-flex-middle" do
        concat(content_tag(:i, '', "uk-icon": "icon: minus-circle"))
        concat(content_tag(:div, "Remove", class: "uk-margin-small-left"))
      end
    end

    def state_toggle_button(resource)
      # TODO add state to collect and send to update method
      link_to [cmsify, :edit,  resource], class: "uk-flex uk-flex-middle" do
        concat(content_tag(:i, '',  "uk-icon": "icon: minus-circle"))
        concat(content_tag(:div, "Deactivate", class: "uk-margin-small-left"))
      end
    end

    def resource_title_header
      cmsify_header(controller_namespace.titleize.pluralize)
    end
  end
end
