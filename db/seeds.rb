# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

User.destroy_all
ActiveRecord::Base.connection.reset_pk_sequence!("users")
Event.destroy_all
ActiveRecord::Base.connection.reset_pk_sequence!("events")

User.create(
  email: "user-1@example.com",
  password: "YTF@qdn1pkg6dmb3mtc",
  first_name: "Bob",
  last_name: "Ross",
  is_admin: true
)
