class AddColumToWordpressMedium < ActiveRecord::Migration[6.0]
  def change
    add_column :wordpress_media, :source_url, :text
  end
end
