class CreateEvents < ActiveRecord::Migration[7.1]
  def change
    create_table :events do |t|
      t.references :user, null: false, foreign_key: true
      t.string :action, null: false
      t.json :data
      t.string :user_agent
      t.string :ip_address

      t.timestamps
    end
  end
end
