class Cmsify::Collection < Cmsify::ApplicationRecord
  include ::Cmsify::StateManager
  include ::Cmsify::ObjectNamable
  include Cmsify::Familial
  include Cmsify::Permanameable

  attr_accessor :configuration

  has_many :collects, class_name: "::Cmsify::Collect", dependent: :destroy
  belongs_to :collection, optional: true
  belongs_to :parent, class_name: "::Cmsify::Collection", foreign_key: :collection_id, optional: true
  has_many :collections
  has_many :children, class_name: "::Cmsify::Collection"
  has_one :attached_featured_image, as: :attachable, class_name: "::Cmsify::Attached::FeaturedImage"
  has_one :featured_image, through: :attached_featured_image, source: :asset

  accepts_nested_attributes_for :collects, allow_destroy: true
  accepts_nested_attributes_for :attached_featured_image, allow_destroy: true, reject_if: proc { |attributes| attributes[:asset_id].blank? }
  accepts_nested_attributes_for :collections

  validates_presence_of :name, :type
  validates_uniqueness_of :slug, scope: :type
  default_scope { order(rank: :asc) }
  scope :without_parent, -> { where({ collection_id: nil }) }
  scope :with_name_keyword, -> (keywords) do
    return none unless keywords.any?
    like_statements = keywords.map { |keyword| "LOWER(name) LIKE (?)" }.join(" OR ")
    keyword_statements = keywords.map { |keyword| "%#{ keyword.downcase }%" }
    where(like_statements, *keyword_statements)
  end

  def self.default_allowed_params
    [
      :name,
      :state,
      :rank,
      :collection_id,
      :apply_access_rules,
      :slug,
      :permaname,
      collects_attributes: ::Cmsify::Collect.default_allowed_params,
      collections_attributes: [:rank, :id],
      attached_featured_image_attributes: ::Cmsify::BaseAttached.default_allowed_params
    ]
  end

  def descendant_item_ids
    descendant_item_ids = items.map(&:id)
    descendant_item_ids += children.map(&:descendant_items).flatten
    descendant_item_ids.uniq!
    descendant_item_ids
  end

  def descendant_items
    "#{ self.class.name.deconstantize }::Item".constantize.where({ id: descendant_item_ids })
  end

  def self.with_accessible_descendant_items_for(current_user, current_ability)
    all.accessible_by(current_ability).find_all do |collection|
      accessible_descendant_items = collection.descendant_items.accessible_by(current_ability)
      (!collection.apply_access_rules? && accessible_descendant_items.any?) || accessible_descendant_items.access_tagged_for(current_user).any?
    end
  end

  def name_with_ancestry
    name_with_ancestry = name
    name_with_ancestry = "#{ collection.name_with_ancestry } > #{ name }" if has_parent?
    name_with_ancestry
  end
  # TODO: items_size is too much of a performance hit, add caching on collection with items_count
  def items_size
    item_sizes = items.size
    item_sizes += collections.sum {|collection| collection.items_size }
    item_sizes
  end

  def is_root?
    #TODO: references to parent collections are not being cleared properly
    collection_id.nil? || collection.nil?
  end
end
