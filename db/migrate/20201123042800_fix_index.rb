class FixIndex < ActiveRecord::Migration[6.0]
  def up
    remove_index :post_tags, name: 'index_post_tags_on_post_and_tag'
    remove_index :post_types, name: 'index_post_types_on_post_and_type'
    remove_index :tag_uris, name: 'index_tag_uris_on_tag_and_original_uri'

    add_index :post_tags, [:post_id, :tag_id], unique: true
    add_index :post_types, [:post_id, :type_id], unique: true
    add_index :tag_uris, [:tag_id, :original_uri], unique: true
  end

  def down
    remove_index :post_tags, name: 'index_post_tags_on_post_id_and_tag_id'
    remove_index :post_types, name: 'index_post_types_on_post_id_and_type_id'
    remove_index :tag_uris, name: 'index_tag_uris_on_tag_id_and_original_uri'

    add_index :post_tags, [:post, :tag], unique: true
    add_index :post_types, [:post, :type], unique: true
    add_index :tag_uris, [:tag, :original_uri], unique: true
  end
end
