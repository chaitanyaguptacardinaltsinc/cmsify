class Cmsify::BaseAttached < Cmsify::ApplicationRecord
  self.table_name = "cmsify_attacheds"

  include Cmsify::StateManager
  belongs_to :asset
  belongs_to :attachable, polymorphic: true, optional: true
  default_scope { order(rank: :asc) }

  def self.default_allowed_params
    [
      :id,
      :_destroy,
      :asset_id,
      :attachable_id,
      :attachable_type,
      :type,
      :alt_title_text
    ]
  end
end
