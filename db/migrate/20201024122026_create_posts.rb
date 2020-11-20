class CreatePosts < ActiveRecord::Migration[6.0]
  def change
    create_table :posts do |t|
      t.string :original_uri, null: false
      t.string :title
      t.datetime :date
      t.references :type, null: false, foreign_key: true
      t.string :html

      t.timestamps
    end
  end
end
