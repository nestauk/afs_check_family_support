class CreateServices < ActiveRecord::Migration[8.0]
  def change
    create_table :services do |t|
      t.string :name, null: false
      t.string :description, null: false
      t.integer :eligible_min_child_age_months
      t.integer :eligible_max_child_age_months
      t.boolean :eligible_parent_carer_status_required
      t.jsonb :eligible_developmental_concerns # TODO: db association?
      t.jsonb :eligible_circumstances # TODO: db association?
      t.boolean :eligible_if_existing_professional_involvement
      t.boolean :eligible_if_motivated
      t.timestamps
    end
  end
end
