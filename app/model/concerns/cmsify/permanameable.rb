module Cmsify::Permanameable
  extend ActiveSupport::Concern

  included do
    after_commit :generate_permaname, unless: :permaname?
  end

  def generate_permaname
    @permaname_attempts = @permaname_attempts.to_i + 1
    update_column :permaname, "#{ self.name.parameterize }#{ @permaname_attempts.to_i > 1 ? "-#{ @permaname_attempts }" : '' }"
  rescue ActiveRecord::RecordNotUnique => e
    retry
  end
  
end
