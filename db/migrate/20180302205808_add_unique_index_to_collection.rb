class AddUniqueIndexToCollection < ActiveRecord::Migration[5.0]
  def up
    Cmsify::Collection.all.select([:slug, "COUNT(*) as count", :type])
      .group([:slug, :type]).reorder(nil).select { |collection_object| collection_object.count > 1 }.each do |obj|
         Cmsify::Collection.where(type: obj.type, slug: obj.slug).each do |collection|
           collection.update(slug: "#{collection.slug}-#{collection.object_id}")
         end
       end
    remove_index :cmsify_collections, [:slug, :type]
    add_index :cmsify_collections, [:slug, :type], unique: true
  end
  def down
    raise ActiveRecord::IrreversibleMigration, "Can't recover the original slug values"
  end
end
