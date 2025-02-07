class Cmsify::Tinymce::AssetSerializer < ActiveModel::Serializer
  attributes :value, :title

  def value
    object.attachment.url
  end

  def title
    object.filename
  end
end
