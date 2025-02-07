class Cmsify::Url < Cmsify::ApplicationRecord
  include ::Cmsify::StateManager
  validates_uniqueness_of :url
  default_scope { order(url: :asc) }

end
