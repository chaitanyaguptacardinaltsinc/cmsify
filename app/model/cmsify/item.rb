class Cmsify::Item < Cmsify::ApplicationRecord
  include ::Cmsify::Filterable
  include ::Cmsify::StateManager
  include Cmsify::Schemable

  attr_reader :configuration

  if ActiveRecord::Base.connection.data_source_exists? :taggings
    acts_as_taggable_on Cmsify.config.access_tags.keys.map { |tag_context| "cmsify_access_tags_#{ tag_context.to_s.singularize }".to_sym }
  end

  has_many :collects, class_name: "::Cmsify::Collect", as: :collectible, dependent: :destroy
  has_many :collections, through: :collects
  accepts_nested_attributes_for :collects, :allow_destroy => true
  
  validates_presence_of :name
  scope :ordered, -> { order(name: :asc) }
  scope :searched_term, -> (searched_term) { search(searched_term) }
  scope :collection, -> (collection_id) do
   joins(collects: :collection).where({ cmsify_collects: { collection_id: collection_id } })
  end

  validates_presence_of :name

  def self.access_tagged_for(current_user)
    Cmsify.config.access_tags.reduce(all) do |memo, (tag_context, tags)|
      # Separately whitelist items not tagged with any tags in a given group group. This is a
      # workaround so that unchecking all access tags in a tag group results in no filtering
      # being applied for that group.
      not_tagged = memo.tagged_with(tags, on: tag_context.to_s.singularize, exclude: true)
      tagged = memo.tagged_with(current_user.try(:access_tags)[tag_context], on:  "cmsify_access_tags_#{ tag_context.to_s.singularize }".to_sym, any: true)
      memo = all.where(id: tagged.map(&:id) + not_tagged.map(&:id))
      memo
    end
  end

  def cmsify_access_tags
    Cmsify.config.access_tags.keys.reduce([]) do |memo, tag_context|
      memo << self.try("cmsify_access_tags_#{ tag_context.to_s.singularize }_list")
      memo
    end.flatten
  end

  def self.default_allowed_params
    [
      :name,
      :state,
      :rank
    ] +
    Cmsify.config.access_tags.keys.reduce([]) do |memo, tag_context|
      tag_context_symbol = "cmsify_access_tags_#{ tag_context.to_s.singularize }_list".to_sym
      memo << tag_context_symbol
      memo << { tag_context_symbol => [] }
      memo
    end
  end

  def configuration=configuration
    @schema = Cmsify.config.fields_for_content_type_schema(self.class.name.deconstantize.demodulize.underscore.to_sym, configuration)

    if required_fields.any?
      class_eval <<-RUBY
        validates_presence_of #{ required_fields }
      RUBY
    end
  end

  private
    def self.search(term)
      where("LOWER(#{table_name}.name) LIKE :term", { term: "%#{term.downcase}%"})
    end

    def table_name
      controller_name.pluralize.underscore
    end
end
