module Cmsify::Filterable
  extend ActiveSupport::Concern
  included do
    scope :start_date, -> (start_date) { where('created_at > ?', start_date.to_datetime - 1.day)}
    scope :end_date, -> (end_date) { where('created_at < ?', end_date.to_datetime + 1.day)}
  end
  module ClassMethods
    def filter_by_scope(filtering_params)
      results = self.where(nil)
      filtering_params.each do |key, value|
        results = results.public_send(key, value) if value.present?
      end
      results
    end
  end
end
