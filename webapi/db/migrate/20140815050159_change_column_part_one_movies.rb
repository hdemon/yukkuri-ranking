class ChangeColumnPartOneMovies < ActiveRecord::Migration
  def change
    change_column :part_one_movies, :video_id, :string, :null => false
    change_column :part_one_movies, :published_at, :date, :null => false
  end
end
