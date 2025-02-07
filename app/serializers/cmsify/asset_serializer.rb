class Cmsify::AssetSerializer < ActiveModel::Serializer
  attributes :id, :url, :type, :filename, :isImage, :extension

  def url
    object.attachment.url
  end

  def type
    object.content_type
  end

  def filename
    object.filename
  end

  def isImage
    object.image?
  end

  def extension
    object.attachment.file.extension
  end
end
