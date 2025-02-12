# lib/cmsify/engine.rb
module Cmsify
  class Engine < ::Rails::Engine
    isolate_namespace Cmsify

    initializer "cmsify.zeitwerk", before: :set_autoload_paths do |app|
      engine_root = root

      # Add main lib directory to autoload paths
      Rails.autoloaders.main.push_dir(engine_root.join('lib').to_s)
      
      # Add specific cmsify directory to autoload paths
      Rails.autoloaders.main.push_dir(engine_root.join('lib/cmsify').to_s)
      
      # Handle concerns directory
      concerns_path = engine_root.join('lib/concerns/cmsify').to_s
      if Dir.exist?(concerns_path)
        Rails.autoloaders.main.collapse(concerns_path)
      end

      # Configure eager load paths
      config.eager_load_paths << engine_root.join('lib').to_s
      config.eager_load_paths << engine_root.join('lib/cmsify').to_s
    end

    config.to_prepare do
      if defined?(Cmsifier)
        Cmsifier.cmsify 
      end
    end

    # Add after_initialize hook to ensure all constants are properly loaded
    config.after_initialize do
      Cmsify::Klass.descendants.each(&:reload)
    end
  end
end