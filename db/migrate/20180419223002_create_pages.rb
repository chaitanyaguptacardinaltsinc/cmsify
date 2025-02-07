class CreatePages < ActiveRecord::Migration[5.1]
  def change
    create_table :cmsify_pages do |t|
      t.string :url
      t.string :path
      t.string :name
      t.string :permaname
      t.string :slug
      t.string :description
      t.string :template
      t.integer :parent_id
      t.string :state, default: "active"
    end
    add_index :cmsify_pages, :parent_id
    add_index :cmsify_pages, :permaname, unique: true
    add_index :cmsify_pages, [:url, :parent_id], unique: true
  end
end
