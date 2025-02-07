class Cmsify::Asset < Cmsify::ApplicationRecord
  include ::Cmsify::Filterable
  include ::Cmsify::StateManager
  DIMENSIONS =  {
    xxxl: "2048 x 2048",
    xxl: "1200 x 1200",
    xl: "1024 x 1024",
    large: "640 x 640",
    medium: "480 x 480",
    small: "240 x 240",
    large_thumb: "160 x 160",
    small_thumb: "80 x 80",
    icon: "32 x 32",
    tiny: "16 x 16",
  }
  mount_uploader :attachment, ::Cmsify::AttachmentUploader
  has_many :attacheds, inverse_of: :asset
  has_many :attachables, through: :attacheds, inverse_of: :asset
  default_scope {order(created_at: :desc)}
  scope :alphabetical, -> { order(attachment: :asc) }  
  scope :images, -> { where("content_type like ?", "%image%") }
  scope :searched_term, -> (searched_term) { search(searched_term) }
  
  # HACK: This is necessary due to a bug in CarrierWave when removing files from nested models
  # See https://github.com/carrierwaveuploader/carrierwave/issues/1801
  def remove_attachment=(value)
    send(:"attachment_will_change!")
    super
  end

  def self.default_allowed_params
    [
      :id,
      :attachment,
      :attachment_cache,
      :remove_attachment
    ]
  end

  def filename
    attachment.file.filename
  end

  def self.search(term)
    where("LOWER(attachment) LIKE :term", { term: "%#{term.downcase}%"})
  end

  def image?
    # HACK: Temporary solution until we store the content type in the database
    ['jpg','png','gif', 'jpeg'].include?(attachment.try(:file).try(:extension).try(:downcase))
  end

end
