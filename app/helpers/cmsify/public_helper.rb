module Cmsify
  module PublicHelper
    def cmsify_flash
      [:notice, :alert, :error].each do |flash_type|
        if flash[flash_type]
          concat(
            content_tag(:div, class: "alert #{ flash_type }", data: { uk_alert: "{}" }) do
              concat('<a class="uk-alert-close close"></a>'.html_safe)
              concat(
                content_tag(:dl) do
                  concat(content_tag :dt, flash_type.to_s.titleize)
                  concat(content_tag :dd, flash[flash_type])
                end
              )
            end
          )
        end
      end
    end

    def cmsify_url_title default_title
      current_url.try(:title) || default_title
    end

    def cmsify_url_description default_description
      current_url.try(:description) || default_description
    end

    def cmsify_admin?
      is_admin?
    end

    def cmsify_tools
      if is_admin?
        cmsify_tool({
          class_name: "cmsify-adminified__toolbar",
          icon_class: "window-maximize",
          href: current_url ? url_for([cmsify, :edit, current_url]) : url_for([cmsify, :new, :url, url: request.path]),
          label: ""
        })
      end
    end

    def cmsify_content_for(collection_name_or_object, options = {}, &block)
      with_cmsify_log_level do
        options = process_options(options)
        collection = Collection.new_find_or_create_by_object_permaname(collection_name_or_object)
        collection.update({ configuration_type: options[:configuration] }) unless collection.send("#{ options[:configuration] }?")
        template_builder = Cmsify::TemplateBuilder.new(collection, app_current_user, current_ability, is_admin?, &block)
        content_items = Cmsify::TemplateBuilder.get_content_items_for_collection(collection, app_current_user, current_ability, is_admin?, options[:params])
        output = ""
        output = capture_yield(template_builder, &block)
        wrapped_output = wrap_output(output, options[:container_html])
        sanitized_output = cmsify_sanitize(wrapped_output)
        adminify sanitized_output, collection, content_items, options, !block_given?
      end
    end

    # TODO: This method needs a lot of cleanup and abstraction
    def cmsify_content object_name, options = {}, &block
      with_cmsify_log_level do
        options = process_options(options)
        collection = get_configured_collection(object_name, options[:configuration])
        output = ""
        # TODO: Move access logic to ability
        if (collection.state == "active" || is_admin?)
          content_items = Cmsify::TemplateBuilder.get_content_items_for_collection(collection, app_current_user, current_ability, is_admin?, options[:params])

          if content_items.any?
            output = content_items.map do |item|
              if block_given? && block.parameters.any?
                item.configuration = collection.configuration_type
                capture_yield(item, &block)
              else
                options[:content_method].to_s.split('.').inject(item, :try)
              end
            end.join("")
          end

          output = output_or_default(output, options[:default], &block)
          wrapped_output = wrap_output(output, options[:container_html])
          sanitized_output = cmsify_sanitize(wrapped_output)
          adminify sanitized_output, collection, content_items, options, !block_given?
        end
      end
    end

    private
      def cmsify_tool(class_name: nil, icon_class:, href:, label:)
        link_to href, data: { turbolinks: false }, class: "cmsify-adminified__content-bar #{class_name || "uk-position-top-right"}" do
          if label.present?
            concat(content_tag(:span, label, class: "uk-margin-small-right"))
          end
          concat( fa_icon(icon_class))
        end
      end

      def current_url
        @current_url ||= Cmsify::TemplateBuilder.accessible_results(Url.all, current_ability, is_admin?).find_by_url(request.path)
      end

      def app_current_user
        defined?(current_user) ? current_user : nil
      end

      def process_options(options)
        if options.is_a?(String)
          options = { default: options }
        end
        options[:configuration] ||= :default
        options[:content_method] ||= "body"
        return options
      end

      def get_configured_collection(name, configuration)
        collection = Collection.find_or_create_by_object_name(name)
        collection.update({ configuration_type: configuration }) unless collection.send("#{ configuration }?")
        return collection
      end

      def output_or_default(output, default_content, &block)
        if output.blank?
          output = case default_content.class.name.demodulize.underscore.to_sym
            when :safe_buffer, :string
              default_content
            when :proc
              capture { default_content.call }
            else
              capture_yield(RecursiveOpenStruct.new(default_content), &block)
            end
        end
        return output
      end

      def wrap_output(output, container_html)
        if container_html.present?
          output = capture do
            content_tag :div, container_html do
              output
            end
          end
        end
        return output
      end

      def with_cmsify_log_level &block
        Rails.logger.silence("Logger::#{ ENV['CMSIFY_LOG_LEVEL'] || 'INFO' }".constantize) { yield }
      end

      def is_admin?
        @is_admin ||= defined?(current_admin) && (current_admin.class.name.downcase.include?("admin") || current_admin.try(:admin?)) && admin_signed_in?
      end

      def adminify(content, collection, content_items, options, is_inline)
        if !is_admin?
          if options[:container]
            content_tag (options[:container].try(:[], :tag) || :div), class: options[:container].try(:[], :class), data: options[:container].try(:[], :data) do
              content
            end
          else
            content
          end
        else
          toolbar = capture do
            cmsify_tool({
              icon_class: "pencil",
              href: edit_url(collection),
              class_name: options[:container].try(:[], :content_bar_class_name),
              label: options[:container].try(:[], :label)
            })
          end
          content_tag((options[:container].try(:[], :tag) || :div), data: options[:container].try(:[], :data), class: "cmsify-adminified #{ 'cmsify-adminified--inline' if is_inline } #{ options[:container].try(:[], :class) }".squish) do
            toolbar + content
          end
        end
      end

      def edit_url(collection)
        components = case collection.items.size
        when 0
          [:new, collection, :item]
        when 1
          [:edit, collection, :item, id: collection.items.first.id]
        else
          [:edit, collection]
        end
        url_for([cmsify] + components)
      end

      def cmsify_sanitize(content)
        scrubber = Loofah::Scrubber.new do |node|
          node.remove if node.name == 'script'
        end

        sanitize(content, scrubber: scrubber)
      end

      def capture_yield(object, &block)
        capture { yield object } if block_given?
      rescue NoMethodError => e
        logger.error e.inspect
        logger.error e.backtrace.join("\n")
        return unless is_admin?

        if object.try(:valid?) == false && object.errors.any?
          error_message = object.errors.full_messages.to_sentence
        else
          error_message = e.message
        end

        output = capture do
          concat(content_tag :p, "Errors on #{ object.try(:name) }: ", class: "cmsify-error")
          concat(content_tag :span, error_message, class: "cmsify-error")
        end

        return output
      end
  end
end
