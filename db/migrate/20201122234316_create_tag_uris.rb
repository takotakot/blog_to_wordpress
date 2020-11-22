class CreateTagUris < ActiveRecord::Migration[6.0]
  def change
    create_table :tag_uris do |t|
      t.references :tag, null: false, foreign_key: true
      t.text :original_uri

      t.timestamps

      t.index [:tag, :original_uri], unique: true
    end
  end
end
