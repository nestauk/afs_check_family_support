require "models/test_case"

class Models::UserTest < Models::TestCase
  test "normalizes" do
    user = User.build(
      first_name: "   First   ",
      last_name: "   Last   ",
      email: "  eMaIl@eXaMpLe.CoM  "
    )

    assert_equal "First", user.first_name
    assert_equal "Last", user.last_name
    assert_equal "email@example.com", user.email
  end

  test "validates presence" do
    user = User.build

    assert !user.valid?
    assert user.errors.has_key?(:first_name)
    assert user.errors.has_key?(:last_name)
    assert user.errors.has_key?(:email)
  end

  test "validates password presence" do
    user = User.build

    assert !user.valid?(:update_password)
    assert user.errors.has_key?(:password)
  end

  def validates(key, value, context = nil)
    user = User.build(key => value)

    assert !user.valid?(context)
    assert user.errors.has_key?(key)
  end
  test "validates email format" do
    validates :email, "not an email"
  end
  test "validates empty password" do
    validates :password, "", :update_password
  end
  test "validates password length" do
    validates :password, "iWj9@TLf0", :update_password
  end
  test "validates pwned passwords" do
    validates :password, "password1234", :update_password
  end
  test "validates password challenge presence" do
    validates :password_challenge, "", :update_password
  end

  test "validates email uniqueness" do
    create :user, email: "user@example.com"
    user = User.build(email: "user@example.com")

    assert !user.valid?
    assert user.errors.has_key?(:email)
  end

  test "valid password challenge" do
    user = create(:user, password: "ravine-lexeme")

    user.update_with_context({password_challenge: "ravine-lexeme"}, :update_password)

    assert !user.errors.has_key?(:password_challenge)
  end
  test "invalid password challenge" do
    user = create(:user, password: "ravine-lexeme")

    user.update_with_context({password_challenge: "wrong password"}, :update_password)

    assert user.errors.has_key?(:password_challenge)
  end
  test "missing password challenge" do
    user = create(:user, password: "ravine-lexeme")

    user.update_with_context({password: "new password"}, :update_password)

    assert user.errors.has_key?(:password_challenge)
  end
end
