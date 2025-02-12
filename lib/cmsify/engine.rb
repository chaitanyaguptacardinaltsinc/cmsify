module Cmsify
  class Engine < ::Rails::Engine
    isolate_namespace Cmsify
    
    config.to_prepare do
      Cmsifier.cmsify if defined?(Cmsifier)
    end
  end
end