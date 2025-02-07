class Cmsify::Collect < Cmsify::ApplicationRecord
  include Cmsify::StateManager
  belongs_to :collection
  belongs_to :collectible, polymorphic: true
  default_scope { order(rank: :asc) }
  accepts_nested_attributes_for :collection, reject_if: :all_blank
  
  def self.default_allowed_params
    [
      :id,
      :_destroy,
      :collection_id,
      :rank,
      collection_attributes: [:id, :_destroy, :name, :type]
    ]
  end
end
