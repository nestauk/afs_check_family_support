class Then
  def initialize(testcase)
    @testcase = testcase
  end

  def and
    self
  end

  def i_see(text)
    @testcase.assert_text text

    self
  end

  def i_do_not_see(text)
    @testcase.assert_no_text text

    self
  end

  def i_see_email(subject, **args)
    expected_count = args[:count] || 1
    emails = ActionMailer::Base.deliveries.select { |m| m.subject == subject }

    @testcase.assert_equal expected_count, emails.count, "Expected to see #{expected_count} #{(expected_count == 1) ? "email" : "emails"} with subject \"#{subject}\", but saw #{emails.count}"

    self
  end
  alias_method :i_see_emails, :i_see_email

  def i_am_on_page(path)
    @testcase.assert_equal path, @testcase.current_path

    self
  end
  alias_method :i_am_redirected_to, :i_am_on_page

  def i_take_snapshot(name)
    window = Capybara.current_session.current_window
    current_window_size = window.size

    # Remove the current focus to prevent the cursor showing up on diffs
    @testcase.page.execute_script("document.activeElement.blur()")

    widths = {desktop: 1280, mobile: 320}
    widths.each do |platform, width|
      window.resize_to(width, 1000)
      height = @testcase.page.evaluate_script("(document.height !== undefined) ? document.height : document.body.offsetHeight")
      window.resize_to(width, height)

      @testcase.save_screenshot "tmp/snapshots/#{name}_#{platform}.png" # standard:disable Lint/Debugger
    end

    # Restore the window size sp other tests aren't affected
    window.resize_to(*current_window_size)

    self
  end

  def the_page_is_accessible
    script = <<~JS
      let js = document.createElement("script");
      js.setAttribute("src", arguments[0]);
      js.setAttribute("type", "module");
      
      let callback = arguments[arguments.length-1];
      js.onload = () => {
        axe.configure({
          reporter: "no-passes",
        })
        axe
          .run({runOnly: {type: 'tag', values: ['wcag2a', 'wcag2aa', 'wcag21a', 'wcag21aa', 'wcag22aa', 'best-practice']}})
          .then(results => {
            callback(results)
          })
          .catch(err => {
            callback(err)
          });
      }
      
      document.body.appendChild(js);
    JS

    result = @testcase.evaluate_async_script(script, ViteRuby.instance.manifest.path_for("accessibility_testing.ts"))

    @testcase.assert result["violations"].length == 0, "Accessibility violations: #{JSON.pretty_generate(result["violations"])}"

    self
  end
end
