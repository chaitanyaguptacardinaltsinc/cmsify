class AddAsideToCmsifyItems < ActiveRecord::Migration[5.1]
  def change
    add_column :cmsify_items, :aside, :text
  end
end
