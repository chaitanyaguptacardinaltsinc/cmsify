module Cmsify
  class Engine < ::Rails::Engine
    isolate_namespace Cmsify

    initializer "cmsify.zeitwerk", before: :set_autoload_paths do |app|
      engine_root = root.to_s
      
      # Add all necessary load paths
      %w(lib lib/cmsify lib/concerns).each do |path|
        full_path = File.join(engine_root, path)
        Rails.autoloaders.main.push_dir(full_path) if Dir.exist?(full_path)
      end

      # Handle nested modules
      Rails.autoloaders.main.collapse(
        "#{engine_root}/lib/concerns/cmsify",
        "#{engine_root}/lib/cmsify"
      )

      # Ignore certain paths if needed
      Rails.autoloaders.main.ignore(
        "#{engine_root}/lib/tasks",
        "#{engine_root}/lib/generators"
      )
    end

    config.to_prepare do
      Cmsifier.cmsify if defined?(Cmsifier)
    end
  end
end