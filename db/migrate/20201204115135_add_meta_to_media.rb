class AddMetaToMedia < ActiveRecord::Migration[6.0]
  def change
    add_column :media, :base_uri, :text
    add_column :media, :last_modified, :datetime
    add_column :media, :meta, :text
  end
end
