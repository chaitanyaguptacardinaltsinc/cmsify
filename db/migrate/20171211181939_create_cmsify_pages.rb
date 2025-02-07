class CreateCmsifyPages < ActiveRecord::Migration[5.0]
  def change
    create_table :cmsify_pages do |t|
      t.string :url
      t.string :title
      t.string :description
      t.string  :state, default: "active"
    end
  end
end
