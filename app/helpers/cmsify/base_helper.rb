module Cmsify
  module BaseHelper
    def cmsify_header(heading)
      cmsify_section do
        concat(render partial: "cmsify/partials/breadcrumbs" )
        concat(content_tag(:h2, heading))
      end
    end

    def cmsify_section(&block)
      content_tag :section, class: "full-width" do
        content_tag :article do
          content_tag :div, class: "uk-width-1-1" do
            yield
          end
        end
      end
    end

    def cmsify_card(class_name = '', &block)
      content_tag :div, class: "card #{ class_name }" do
        yield
      end
    end

    def primary_button(label, path, html_class)
      link_to label, path, class: "button#{ " " + html_class if html_class.present? }"
    end

    def secondary_button(label, path, html_class)
      primary_button label, path, "secondary#{ " " + html_class if html_class.present? }"
    end

    def back_button
      secondary_button "Cancel", :back, "uk-margin-small-right"
    end

    def cmsify_form_for(path, options = {}, &block)
      options = options.deep_merge(html: { class: 'js-changed-form-modal' }) unless options[:track_changes] == false
      simple_form_for(path, options, &block)
    end

    def cmsify_field f, field_name, schema_options={}
      # TODO: We need to be able to pass all input options, placeholder, class, input_html, not just label
      input_options = { label: schema_options[:label] }
      content_tag :div, class: "row #{"uk-invisible uk-animation-fade" if [:text, :datetime].include?(schema_options[:type])}" do
        case schema_options[:type]
          when :year
            input_options = input_options.deep_merge(as: :date, discard_month: true,
              discard_day: true, start_year: Date.today.year - 50, end_year: Date.today.year)
            f.input field_name, input_options
          when :string
            f.input field_name, input_options
          when :text
            concat(f.input field_name, input_options.deep_merge(input_html: { class: 'tinymce' }))
            if schema_options[:hint].present?
              concat(content_tag(:div, class: "uk-text-muted") { schema_options[:hint] })
            end
          when :datetime
            input_options = input_options.deep_merge(as: :string, input_html: { class: "js-flatpickr" }, placeholder: input_options[:label])
            f.input field_name, input_options
        end
      end
    end

    def delete_button(resource)
      link_to [cmsify, resource], method: :delete, data: { confirm: 'Are you sure?' }, class: "uk-flex uk-flex-middle" do
        concat(content_tag(:i, '', "uk-icon": "icon: trash"))
        concat(content_tag(:div, "Delete", class: "uk-margin-small-left"))
      end
    end

    def submit_section(f)
      cmsify_section do
        content_tag :div, class: "uk-flex uk-flex-right" do
          concat(area :submit)
          concat(f.submit 'Save', class: 'button primary')
        end
      end
    end

    def status_for_resource(resource)
      content_tag :span, class: "tip #{ resource.active? ? 'uk-text-success' : 'uk-text-warning' }",
        data: { hover: resource.state.capitalize } do
          "&#9679;".html_safe
      end
    end

    def descendents_accordion resource, current_node, index = 0
      content_tag(:li, class: "#{"uk-parent" if current_node.children.size > 0} #{"uk-open" if resource && resource.has_ancestor?(current_node)}") do
        concat(
          content_tag(:div, class: "uk-flex uk-flex-middle blm-uk-nav-row", style: "padding-left: #{ (index + 1) * 15 }px") do
            concat(content_tag(:div, "", class: "uk-flex-none blm-uk-nav-spacer #{"blm-uk-nav-toggle" if current_node.children.size > 0}"))
            concat(active_link_to(current_node.name, [cmsify, :edit, current_node], class: "uk-flex-1"))
            concat(
              content_tag(:div, class: "uk-flex uk-flex-middle uk-flex-none uk-margin-small-left") do
                if resource == current_node
                  if current_node.children.size > 1
                    concat( link_to("", "#", "uk-toggle": "target: #manage-child-collections", class: "button transparent secondary icon-move-vertical"))
                  end
                  concat(link_to("", "#", "uk-toggle": "target: #offcanvas-collection", class: "button transparent secondary icon-edit"))
                  concat( link_to("", [cmsify, :new,  current_node, :child], class: "button transparent secondary icon-addcircle"))
                end
              end
            )
          end
        )
        concat(
          content_tag(:ul, class: "uk-nav-default uk-nav-parent-icon", "uk-nav": "toggle: > div > .blm-uk-nav-toggle; multiple: true;") do
            current_node.children.each do |child|
              concat(descendents_accordion(resource, child, index + 1))
            end
          end
        )
      end
    end
  end
end
