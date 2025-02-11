module Cmsify
  class Engine < ::Rails::Engine
    isolate_namespace Cmsify

    # Update autoloading configuration for Zeitwerk
    initializer "cmsify.autoload", before: :set_autoload_paths do |app|
      app.config.autoload_paths << "#{root}/lib"
      app.config.eager_load_paths << "#{root}/lib"
      
      # If you have nested directories in lib that need autoloading
      Dir["#{root}/lib/**/"].each do |path|
        app.config.autoload_paths << path
        app.config.eager_load_paths << path
      end
    end

    # Move the cmsifier initialization to after autoloading is set up
    config.after_initialize do
      Rails.application.config.to_prepare do
        Cmsifier.cmsify
      end
    end
  end
end