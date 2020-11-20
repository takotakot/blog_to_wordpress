class CreateMedia < ActiveRecord::Migration[6.0]
  def change
    create_table :media do |t|
      t.boolean :is_internal, null: false
      t.string :original_src, null: false
      t.string :server_path, null: false
      t.string :name, null: false
      t.string :local_path, null: false
      t.date :date_loaded, null: false
      t.date :oldest_date, null: false

      t.timestamps
    end
  end
end
