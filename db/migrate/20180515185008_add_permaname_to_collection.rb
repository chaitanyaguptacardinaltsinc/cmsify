class AddPermanameToCollection < ActiveRecord::Migration[5.1]
  def up
    add_column :cmsify_collections, :permaname, :string
    add_index :cmsify_collections, :permaname, unique: true
    Cmsify::Collection.all.each { |collection| collection.save }
  end

  def down
    remove_column :cmsify_collections, :permaname, :string
  end
end
