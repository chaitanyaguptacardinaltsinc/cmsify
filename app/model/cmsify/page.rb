class Cmsify::Page < Cmsify::ApplicationRecord
  include Cmsify::StateManager
  include Cmsify::Familial
  include Cmsify::Permanameable

  belongs_to :parent, class_name: "Cmsify::Page", foreign_key: :parent_id, optional: true
  has_many :pages, foreign_key: :parent_id
  has_many :children, class_name: "Cmsify::Page", foreign_key: :parent_id

  validates_uniqueness_of :url, scope: :parent_id

  before_save :set_path


  def parent_path
    path = self.parent.try(:parent_path) || ""
    path += "#{ self.parent.try(:url) }/"
    return path
  end

  private
    def set_path
      self.path = "#{ parent_path }#{ url }"
    end

end
