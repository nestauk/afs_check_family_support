class Given
  def initialize(testcase)
    @testcase = testcase
  end

  def and
    self
  end

  def i_am_signed_in
    i_am_signed_in_as @testcase.create(:user)

    self
  end

  def i_am_signed_in_as user
    @testcase.visit "/auth"
    @testcase.fill_in "email", with: user.email
    @testcase.fill_in "password", with: user.password
    @testcase.click_on "Sign in"

    self
  end
end
