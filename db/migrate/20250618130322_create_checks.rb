class CreateChecks < ActiveRecord::Migration[8.0]
  def change
    create_table :checks do |t|
      t.references :profile, null: false, foreign_key: true
      t.references :service, null: false, foreign_key: true
      t.boolean :eligible, null: false
      t.jsonb :reasons
      t.timestamps
    end
  end
end
