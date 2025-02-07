# encoding: utf-8

class Cmsify::AttachmentUploader < CarrierWave::Uploader::Base

  # Include RMagick or MiniMagick support:
  # include CarrierWave::RMagick
  include CarrierWave::MiniMagick

  # Choose what kind of storage to use for this uploader:
  # storage :file
  storage Cmsify.config.asset_storage

  # Override the directory where uploaded files will be stored.
  # This is a sensible default for uploaders that are meant to be mounted:
  def store_dir
    "#{ Cmsify.config.asset_store_dir }/uploads/#{ model.model_name.element }/#{ model.id }/#{ mounted_as }"
  end

  # Save content_type and file size to the model
  process :save_content_type_and_size_in_model

  # Provide a default URL as a default if there hasn't been a file uploaded:
  # def default_url
  #   # For Rails 3.1+ asset pipeline compatibility:
  #   # ActionController::Base.helpers.asset_path("fallback/" + [version_name, "default.png"].compact.join('_'))
  #
  #   "/images/fallback/" + [version_name, "default.png"].compact.join('_')
  # end

  # Process files as they are uploaded:

  process :store_dimensions, if: :image?
  version :xxxl, if: :image? do
    process :resize_to_limit => [2048, 2048]
  end
  version :xxl, from_version: :xxxl, if: :image? do
    process :resize_to_limit => [1200, 1200]
  end
  version :xl, from_version: :xxl, if: :image? do
    process :resize_to_limit => [1024, 1024]
  end
  version :large, from_version: :xl, if: :image? do
    process :resize_to_limit => [640, 640]
  end
  version :medium, from_version: :large, if: :image? do
    process :resize_to_limit => [480, 480]
  end
  version :small, from_version: :medium, if: :image? do
    process :resize_to_limit => [240, 240]
  end
  version :large_thumb, from_version: :small, if: :image? do
    process :resize_to_limit => [160, 160]
  end
  version :small_thumb, from_version: :large_thumb, if: :image? do
    process :resize_to_limit => [80, 80]
  end
  version :icon, from_version: :small_thumb, if: :image? do
    process :resize_to_limit => [32, 32]
  end
  version :tiny, from_version: :icon, if: :image? do
    process :resize_to_limit => [16, 16]
  end

  # Add a white list of extensions which are allowed to be uploaded.
  # For images you might use something like this:
  # def extension_white_list
  #   %w(jpg jpeg gif png)
  # end

  # Override the filename of the uploaded files:
  # Avoid using model.id or version_name here, see uploader/store.rb for details.
  # def filename
  #   "something.jpg" if original_filename
  # end
  private

  def store_dimensions
    if file && model
      model.width, model.height = ::MiniMagick::Image.open(file.file)[:dimensions]
    end
  end

  def image?(new_file)
    new_file.content_type.start_with? 'image'
  end

  def save_content_type_and_size_in_model
    model.content_type = file.content_type
    model.size = file.size
  end
end
