class CreatePostMedia < ActiveRecord::Migration[6.0]
  def change
    create_table :post_media do |t|
      t.references :post, null: false, foreign_key: true
      t.references :medium, null: false, foreign_key: true

      t.timestamps
      t.index [:post_id, :medium_id], unique: true
    end
  end
end
