class ModifyMedia < ActiveRecord::Migration[6.0]
  def change
    rename_column :media, :name, :title
    add_column :media, :alt, :text, null: false, after: :title
    add_column :media, :uri, :text, null: false, after: :original_src
    add_column :media, :status, :int, null: false, after: :local_path, default: 0
  end
end
