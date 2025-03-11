class Ahoy::Store < Ahoy::DatabaseStore
end

# Enable the API for JavaScript tracking
Ahoy.api = true

# set to true for geocoding (and add the geocoder gem to your Gemfile)
# we recommend configuring local geocoding as well
# see https://github.com/ankane/ahoy#geocoding
Ahoy.geocode = false

# Disable bot protection in the test environment
Ahoy.track_bots = Rails.env.test?

Ahoy.cookies = :none
