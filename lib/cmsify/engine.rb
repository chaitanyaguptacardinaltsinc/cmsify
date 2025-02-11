# lib/cmsify/engine.rb
module Cmsify
  class Engine < ::Rails::Engine
    isolate_namespace Cmsify

    initializer "cmsify.zeitwerk", before: :set_autoload_paths do |app|
      Rails.autoloaders.main.push_dir(root.join('lib').to_s)
      Rails.autoloaders.main.push_dir(root.join('lib/cmsify').to_s)
      
      # If you need to keep concerns in the original location
      Rails.autoloaders.main.collapse(
        "#{root}/lib/concerns/cmsify"
      )
    end

    config.to_prepare do
      Cmsifier.cmsify if defined?(Cmsifier)
    end
  end
end