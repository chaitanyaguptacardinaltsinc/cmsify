module Cmsify
  module StateManager
    PUBLISH_STATES = ['Active', 'Inactive'].map{|s| [s, s.downcase]}.to_h

    extend ActiveSupport::Concern
    included do
      validates_presence_of :state
      scope :active, -> { where(state: :active) }
      state_machine initial: :active  do
        state :inactive do
        end
        state :deleted do
        end
      end
    end
  end
end
