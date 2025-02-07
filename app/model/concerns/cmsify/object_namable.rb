module Cmsify::ObjectNamable
  extend ActiveSupport::Concern
  MAX_RETRIES = 5

  included do
    after_commit :generate_object_id, unless: :object_id?, prepend: true
    after_commit :generate_slug, unless: :slug?

    validates_uniqueness_of :permaname, scope: :type

    def self.find_or_create_by_object_name object_name
      matched = object_name.match(/(.*?) : (.*?) : (.*?) : (\w{6})$/)
      type_name = "#{ matched.try(:[], 1).try(:gsub, /\s+/, "") }::#{ matched.try(:[], 2) }"
      self.find_or_create_by!({ type: "Cmsify::#{ type_name }", object_id: matched.try(:[], 4) }) do |collection|
        collection.name = matched.try(:[], 3)
      end
    rescue ActiveRecord::RecordNotUnique => e
      # TODO: Handle existing ID of a different type
    end

    def self.new_find_or_create_by_object_permaname friendly_permaname
      matched = friendly_permaname.match(/(.*?) : (.*?) : (.*?)$/)
      name = matched.try(:[], 3)
      type_name = "#{ matched.try(:[], 1).try(:gsub, /\s+/, "") }::#{ matched.try(:[], 2) }"
      self.create_with({ name: name }).find_or_create_by!({ permaname: name.parameterize, type: "Cmsify::#{ type_name }" }) #
    end
  end

  def object_name
    "#{ self.class.name.deconstantize.demodulize } : #{ self.class.name.demodulize.gsub(/::/, ' : ').titleize } : #{ permaname } : #{ object_id }"
  end

  def new_object_name
    "#{ self.class.name.deconstantize.demodulize } : #{ self.class.name.demodulize.gsub(/::/, ' : ').titleize } : #{ permaname }"
  end

  private
    def generate_object_id
      update_column :object_id, SecureRandom.hex(3)
    rescue ActiveRecord::RecordNotUnique => e
      @attempts = @attempts.to_i + 1
      retry if @attempts < MAX_RETRIES
      raise e, "Retries exhausted"
    end

    def generate_slug
      @slug_attempts = @slug_attempts.to_i + 1
      update_column :slug, "#{ self.name.parameterize }#{ @slug_attempts.to_i > 1 ? "-#{ @slug_attempts }" : '' }"
    rescue ActiveRecord::RecordNotUnique => e
      retry
    end
end
