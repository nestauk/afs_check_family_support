class CreateFavourites < ActiveRecord::Migration[8.0]
  def change
    create_table :favourites do |t|
      t.references :profile, null: false, foreign_key: true
      t.references :provision, null: false, foreign_key: true

      t.timestamps
    end

    add_index :favourites, [:profile_id, :provision_id], unique: true
  end
end
