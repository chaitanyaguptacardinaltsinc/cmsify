require 'active_record'
require 'active_record/version'
require 'active_support/core_ext/module'
require 'state_machines-activerecord'
require 'acts-as-taggable-on'
require 'responders'
require 'carrierwave'
require 'carrierwave/storage/abstract'
require 'carrierwave/storage/file'
require 'carrierwave/storage/fog'
require 'kaminari'
require 'breadcrumbs_on_rails'
require 'active_link_to'
require 'mini_magick'
require 'simple_form'
require 'nestive'
require "cocoon"
require "active_model_serializers"
require "recursive-open-struct"
require "font-awesome-rails"
require_relative "cmsify/configuration"
require_relative "cmsify/klass"
require_relative "cmsify/schemable"
require_relative "cmsify/cmsifier"
begin
  require 'rails/engine'
  require 'cmsify/engine'
  rescue LoadError
end

module Cmsify
  extend ActiveSupport::Autoload

  autoload :Cmsified
  autoload :Schemable
  autoload :Klass
  autoload :Cmsified
  RESOURCE_TYPES = [:item, :collection]

  class << self
    attr_accessor :config
  end

  def self.setup
    # Need to load the devise initializer in case a devise-enabled class is auto-loaded (ie. Admin)
    devise_initializer = "#{Rails.root}/config/initializers/devise.rb"
    load devise_initializer if File.exist? devise_initializer

    self.config ||= Configuration.new
    yield(config)
    self.config.configure_carrier_wave

    # DANGEROUS: Eager load all classes to ensure that `cmsify` class method is run on individual
    # model classes. This may need to be replaced with something like:
    # `config.extra_models = ["Admin", "EnablementDetail"]`
    Rails.application.eager_load!
  end

  def self.root
    File.dirname __dir__
  end
end

ActiveSupport.on_load(:active_record) do
  extend Cmsify::Cmsified
end
