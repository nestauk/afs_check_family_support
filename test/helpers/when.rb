class When
  def initialize(testcase)
    @testcase = testcase
  end

  def and
    self
  end

  def i_visit(url)
    @testcase.visit url

    status = @testcase.status_code
    @testcase.assert_equal 200, status, "#{url} returned status #{status}, expected 200"

    self
  end

  def i_refresh
    @testcase.refresh

    self
  end

  def i_enter value, args
    nth = args.delete(:nth)
    if nth.present?
      @testcase.page.all(args[:into])[nth].set value
    else
      @testcase.fill_in args.delete(:into), with: value, **args
    end

    self
  end
  alias_method :i_type, :i_enter

  def i_press text = nil, **options
    if options.has_key? :aria_label
      @testcase.find(%([aria-label="#{options[:aria_label]}"])).click
    elsif options.has_key? :selector
      @testcase.find(:css, options.delete(:selector), **options).click
    else
      @testcase.click_button text, **options
    end

    self
  end

  def i_click text, **args
    @testcase.click_link text

    self
  end

  def i_click_text text, **args
    @testcase.find(args[:selector] || "*", text: text, match: :prefer_exact).click

    self
  end

  def i_click_in_email text
    html = Nokogiri::HTML(ActionMailer::Base.deliveries.last.html_part.body.to_s)
    @testcase.visit html.at("a:contains(\"#{text}\")")["href"]

    self
  end

  def i_wait_for duration
    sleep duration

    self
  end
end
