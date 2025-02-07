module Cmsify
  class Engine < ::Rails::Engine
    config.autoload_paths += Dir["#{config.root}/lib/**/"]
    isolate_namespace Cmsify

    config.to_prepare do
      Cmsifier.cmsify
    end
  end
end
