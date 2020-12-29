class CreateWordpressMedia < ActiveRecord::Migration[6.0]
  def change
    create_table :wordpress_media do |t|
      t.references :medium, null: false, foreign_key: true
      t.bigint :wp_id
      t.integer :status, null: false, default: 0
      t.datetime :date
      t.bigint :wp_post_id
      t.text :title
      t.text :alt_text
      t.integer :version, null: false

      t.timestamps

      t.index :status
      t.index :wp_id, unique: true
      t.index :wp_post_id, unique: true
    end
  end
end
