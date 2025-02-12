module Cmsify
  class Engine < ::Rails::Engine
    isolate_namespace Cmsify

    initializer "cmsify.zeitwerk", before: :set_autoload_paths do |app|
      engine_root = root.to_s
      
      # Add the correct paths
      Rails.autoloaders.main.push_dir("#{engine_root}/lib")
      Rails.autoloaders.main.push_dir("#{engine_root}/lib/cmsify")
    end

    config.to_prepare do
      Cmsifier.cmsify if defined?(Cmsifier)
    end
  end
end