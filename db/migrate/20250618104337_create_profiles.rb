class CreateProfiles < ActiveRecord::Migration[8.0]
  def change
    create_table :profiles do |t|
      t.string :child_first_name, null: false
      t.boolean :legal_parent_or_carer, null: false
      t.date :child_date_of_birth, null: false
      t.string :current_post_code
      t.boolean :existing_professional_involvement
      t.jsonb :developmental_concerns # TODO: db association?
      t.jsonb :circumstances # TODO: db association?
      t.boolean :motivated
      t.timestamps
    end
  end
end
