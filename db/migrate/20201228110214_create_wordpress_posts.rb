class CreateWordpressPosts < ActiveRecord::Migration[6.0]
  def change
    create_table :wordpress_posts do |t|
      t.references :post, foreign_key: true
      t.bigint :wp_id
      t.integer :status, null: false, default: 0
      t.text :slug
      t.text :title
      t.text :content, limit: 4294967295
      t.datetime :date
      t.integer :version, null: false

      t.timestamps

      t.index :status
      t.index :wp_id, unique: true
    end
  end
end
