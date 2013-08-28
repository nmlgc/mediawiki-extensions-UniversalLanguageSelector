Given(/^I set "(.*?)" as the interface language$/) do |language|
	code = language_to_code(language)
	visit(ULSPage, :using_params => {:setlang => "#{code}"})
	# And check it took effect
	actual = @browser.execute_script( "return jQuery( 'html' ).attr( 'lang' )" )
	actual.should == code
end

Given(/^the content language is "(.*?)"$/) do |language|
	code = language_to_code(language)
	actual = @browser.execute_script( "return mw.config.get( 'wgContentLanguage' )" )
	actual.should == code
end

Given(/^I inspect current fonts$/) do
	@original_content_font = get_content_font()
	@original_interface_font = get_interface_font()
end

When(/^I open "(.*?)" panel of language settings$/) do |panel|
	# These can be of two different type of elements, which PageObjects do not like.
	@browser.execute_script(
		"jQuery( '.uls-trigger, .uls-settings-trigger' ).eq( 0 ).click()"
	)
	on(ULSPage) do |page|
		case panel
		when "Display"
			page.panel_display_element.click
		when "Language"
			page.panel_display_element.click
			page.panel_language_element.click
		when "Fonts"
			page.panel_display_element.click
			page.panel_fonts_element.click
		when "Input"
			page.panel_input_element.click
		else
			pending
		end
	end
end

When(/^I select "(.*?)" font for the (.*?) language for the live preview$/) do |font,type|
	if type == 'interface'
		type = 'ui'
	end
	Selenium::WebDriver::Support::Select.new(
		@browser.driver.find_element(:id, "#{type}-font-selector")
	).select_by(:text, font)
end

When(/^I close the panel to discard the changes$/) do
	on(ULSPage).panel_button_close_element.click
end

Then(/^the active (.*?) font must be the same as font prior to the preview$/) do |type|
	case type
	when "content"
		get_content_font().should === @original_content_font
	when "interface"
		get_interface_font().should === @original_interface_font
	else
		pending
	end
end

Then(/^the selected (.*?) font must be "(.*?)"$/) do |type, font|
	if type == 'interface'
		type = 'ui'
	end
	step 'I open "Fonts" panel of language settings'
	Selenium::WebDriver::Support::Select.new(
		@browser.driver.find_element(:id, "#{type}-font-selector")
	).first_selected_option().attribute('value').should == font
end

When(/^I apply the changes$/) do
	on(ULSPage).panel_button_display_apply_element.click
	wait = Selenium::WebDriver::Wait.new(:timeout => 3)
	panel = @browser.driver.find_element(:id => 'language-settings-dialog')
  wait.until { !panel.displayed? }
end

Then(/^the (.*) font must be changed to the "(.*?)" font$/) do |type, font|
	case type
	when "content"
		get_content_font().should match("^#{font}")
	when "interface"
		get_interface_font().should match("^#{font}")
	else
		pending
	end
end

Then(/^I can disable input methods$/) do
	on(ULSPage).panel_disable_input_methods_element.click
end

Then(/^I can enable input methods$/) do
	on(ULSPage).panel_enable_input_methods_element.click
end

Then(/^a font selector for interface language appears$/) do
  on(ULSPage).panel_interface_font_selector_element.should be_visible
end

Then(/^a font selector for content language appears$/) do
  on(ULSPage).panel_content_font_selector_element.should be_visible
end
