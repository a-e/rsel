Rsel History
============

0.0.6
-----

- Added stop_on_error attribute, to raise an exception when a step fails
- Allow execution of arbitrary Selenium::Client::Driver methods
- Separated support methods from SeleniumTest methods


0.0.5
-----

- Allow Selenium-style locators beginning with id=, name=, xpath=, css= etc.
- Raise a StopTest exception when Selenium is not running (requires updated rubyslim)
- Locators are now documented
- Example FitNesse tables are now included


0.0.4
-----

- Added `in_row` to scope, for narrowing scope to a specific table row
- Many more methods accept scope hash now
- Added (working) `radio_is_enabled` and `radio_is_disabled` methods


0.0.3
-----

- Added `row_exists`, for verifying the presence of a table row
- Added `scope` hash with support for `within` clause on most methods
- Bugfix for `pause_seconds` (was waiting 1000 times too long)
- Fix behavior of enable/disable checkbox, so onclick events will fire
- Tell Selenium to highlight located elements
- XPath 0.1.4 is now required


0.0.2
-----

- Added `dropdown_includes` and `dropdown_equals`
- Added `link_exists` and `button_exists`


0.0.1
-----

- Basic visibility, navigation, form fill-in and validation methods

