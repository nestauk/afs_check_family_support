class CreateProvisions < ActiveRecord::Migration[8.0]
  def change
    create_table :provisions do |t|
      t.references :provider, null: false, foreign_key: true
      t.references :service, null: false, foreign_key: true
      t.text :how_to_sign_up

      t.timestamps
    end
  end
end
