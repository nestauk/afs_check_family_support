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
  is_admin: true,
)

Service.destroy_all
ActiveRecord::Base.connection.reset_pk_sequence!("services")

Service.create!(
  name: "Empowering Parents, Empowering Communities (EPEC)",
  description: "A parenting programme that supports parents to develop their skills and confidence in parenting.",
  eligible_min_child_age_months: 24,
  eligible_max_child_age_months: 132,
  eligible_parent_carer_status_required: true,
  eligible_developmental_concerns: ["Child behaviour problems"],
  eligible_circumstances: ["Income difficulties", "Social exclusion"],
  eligible_if_existing_professional_involvement: true,
  eligible_if_motivated: true,
)

Service.create!(
  name: "Triple P Online",
  description: "An online parenting programme that provides parents with strategies to manage their child's behaviour.",
  eligible_min_child_age_months: 12,
  eligible_max_child_age_months: 36,
  eligible_parent_carer_status_required: true,
)

Service.create(
  name: "Incredible Years Pre-School ",
  description: "A parenting programme designed to support parents of children aged 3-6 years in managing their child's behaviour and promoting positive development.",
  eligible_min_child_age_months: 36,
  eligible_max_child_age_months: 72,
  eligible_parent_carer_status_required: true,
)
