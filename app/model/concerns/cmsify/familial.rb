module Cmsify::Familial
  extend ActiveSupport::Concern

  included do
    scope :without_parent, -> { where({ parent_id: nil }) }
  end

  def ancestor_ids
    ancestor_ids = [id]
    ancestor_ids += parent.ancestor_ids if has_parent?
    ancestor_ids
  end

  def has_ancestor? object
    ancestor_ids.include? object.id
  end

  def is_root?
    #TODO: references to parent collections are not being cleared properly
    parent_id.nil? || parent.nil?
  end

  def has_parent?
    !is_root?
  end
end
