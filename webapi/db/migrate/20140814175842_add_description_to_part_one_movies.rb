class AddDescriptionToPartOneMovies < ActiveRecord::Migration
  def change
    add_column :part_one_movies, :description, :text
  end
end
