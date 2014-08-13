class CreatePartOneMovie < ActiveRecord::Migration
  def change
    create_table :part_one_movies do |t|
      t.string :video_id
      t.date :published_at
    end
  end
end
