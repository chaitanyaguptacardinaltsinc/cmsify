class Cmsify::ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  class << self
    if ActiveRecord::Base.respond_to?(:accessible_by)
      alias :base_accessible_by :accessible_by
    end
  end

  def self.accessible_by(ability)
    if self.respond_to?(:base_accessible_by) && ability
      self.base_accessible_by(ability)
    else
      all
    end
  end
end
