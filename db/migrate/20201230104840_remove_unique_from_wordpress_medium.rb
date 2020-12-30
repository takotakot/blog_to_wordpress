class RemoveUniqueFromWordpressMedium < ActiveRecord::Migration[6.0]
  def up
    remove_index :post_tags, name: 'index_wordpress_media_on_wp_post_id'
    add_index :wordpress_media, [:wp_post_id], unique: false
  end
  def down
    remove_index :post_tags, name: 'index_wordpress_media_on_wp_post_id'
    add_index :wordpress_media, [:wp_post_id], unique: true
  end
end
