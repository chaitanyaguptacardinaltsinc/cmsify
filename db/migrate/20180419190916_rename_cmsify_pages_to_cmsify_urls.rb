class RenameCmsifyPagesToCmsifyUrls < ActiveRecord::Migration[5.1]
  def change
    rename_table :cmsify_pages, :cmsify_urls
  end
end
