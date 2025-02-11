module Cmsify
  class Configuration
    attr_accessor :app_name, :sign_out_path, :stylesheet, :branding, :asset_store_dir, :cmsified,
      :asset_storage, :access_tags

    attr_writer :schema

    def initialize
      @schema = {}
      @cmsified = {}
      @app_name = Rails.application.class.name.deconstantize.titleize
      @asset_storage = :fog
    end

    def schema
      @schema.merge(@cmsified)
    end

    def configured_schema
      @configured_schema = @schema.merge(@cmsified).reduce({}) do |memo, (content_type, content_type_schema)|
        memo[content_type] = content_type_schema[:configurations].present? ? content_type_schema : { configurations: { default: content_type_schema } }
        memo
      end
    end

    def content_types
      @schema.keys
    end

    def cmsified_models
      cmsified.keys.to_a.uniq
    end

    def cmsified_resources
      cmsified_models.map(&:to_s).map(&:tableize)
    end

    def branding
      @branding ||= app_name
    end

    def asset_store_dir
      @asset_store_dir || 'cmsify'
    end

    def content_type_classes
      content_types.map(&:to_s).map(&:classify)
    end

    def asset_fields_for_content_type(content_type)
      configured_schema[content_type][:configurations].reduce({}) do |memo, (configuration_name, configuration)|
        asset_fields_for_content_type_schema(content_type, configuration_name).each do |asset_field_name, asset_field|
          memo[asset_field_name] = asset_field unless memo.keys.include?(asset_field_name)
        end
        memo
      end
    end

    def image_fields_for_content_type_schema(content_type, configuration = :default)
      fields_for_content_type_schema(content_type, configuration, :image)
    end

    def attachment_fields_for_content_type_schema(content_type, configuration = :default)
      fields_for_content_type_schema(content_type, configuration, :attachment)
    end

    def asset_fields_for_content_type_schema(content_type, configuration = :default)
      fields_for_content_type_schema(content_type, configuration, [:image, :attachment])
    end

    def fields_for_content_type_schema(content_type, configuration = nil, field_types = nil)
      return unless configured_schema[content_type]
      schema_fields = configured_schema[content_type][:configurations][configuration.try(:to_sym) || :default]
      if field_types.present?
        field_types = field_types.is_a?(Array) ? field_types : [field_types]
        schema_fields.select { |field_name, field| field_types.include? field[:type] }
      else
        schema_fields
      end
    end

    def mass_assignable_fields_for_content_type_configuration(content_type, configuration = :default)
      schema ||= self.fields_for_content_type_schema(content_type, configuration)
      schema.select { |field_name, field| field[:protected] != true }.reduce([]) do |memo, (field_name, field)|
        if [:attachment, :image].include?(field[:type])
          memo.push({ "attached_#{ field_name }_attributes".to_sym => ::Cmsify::BaseAttached.default_allowed_params })
        else
          memo.push(field_name)
        end
        memo
      end
    end

    def configure_carrier_wave
      CarrierWave.configure do |config|
        if self.asset_storage == :fog
          config.fog_credentials = {
            provider:              'AWS',                        # required
            aws_access_key_id:     ENV['AWS_ACCESS_KEY_ID'],                        # required
            aws_secret_access_key: ENV['AWS_SECRET_ACCESS_KEY'],                        # required
            region:                ENV['AWS_REGION'],                 # optional, defaults to 'us-east-1'
            # host:                  's3.example.com',             # optional, defaults to nil
            # endpoint:              'https://s3.example.com:8080' # optional, defaults to nil
          }
          config.fog_directory  = ENV['AWS_BUCKET_NAME']  # required
          config.asset_host     = "https://#{ ENV['KEY_CDN_ZONE_URL'] }"

          config.fog_public     = true             # optional, defaults to true
          # config.storage = :fog
          config.fog_attributes = { 'Cache-Control' => "max-age=#{365.day.to_i}" } # optional, defaults to {}
        end
      end
    end
  end
end  