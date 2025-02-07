# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'cmsify/version'

Gem::Specification.new do |spec|
  spec.name          = "cmsify"
  spec.version       = Cmsify::VERSION
  spec.authors       = ["Andrew Shenstone, Josh Reeves"]
  spec.email         = ["development@plyinteractive.com"]
  spec.summary       = ["Cmsify allows dynamic generation of maintainable content for your web project"]
  spec.homepage      = "http://www.plyinteractive.com"
  spec.license       = ""

  spec.files = Dir["{app,config,db,lib}/**/*", "Rakefile", "README.rdoc"]
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "2.6.3"
  spec.add_development_dependency "rake"
  # TODO: Add cmsify assets as a dependency
  # spec.add_dependency 'cmsify_assets'
  spec.add_dependency "responders"
  spec.add_dependency "acts-as-taggable-on"
  spec.add_dependency "nestive"
  spec.add_dependency "simple_form"
  spec.add_dependency "cocoon"
  spec.add_dependency "active_model_serializers"
  spec.add_dependency "state_machines-activerecord"
  spec.add_dependency "carrierwave", '~> 0.11.2'
  spec.add_dependency "fog-aws"
  spec.add_dependency "kaminari"
  spec.add_dependency "breadcrumbs_on_rails"
  spec.add_dependency "active_link_to"
  spec.add_dependency "mini_magick"
  spec.add_dependency "recursive-open-struct"
  spec.add_dependency "font-awesome-rails"
end
