Rsel History
============

0.0.9
-----

- stop_on_error renamed to stop_on_failure
- stop_on_failure now causes all subsequent steps to fail, instead of raising exception
- Added begin_scenario and end_scenario to reset the found_failure flag


0.0.8
-----

- Use javascript-xpath to dramatically improve speed on MSIE
- Documentation on Scenarios and non-FitNesse usage
- Minor spec test cleanup


0.0.7
-----

- Indicate pass/fail status for Selenium::Client::Driver wrapped methods
- Allow passing stop_on_error to SeleniumTest constructor
- Auto-strip HTML in URL passed to constructor
- Button, field, checkbox, and radiobutton edits fail on disabled inputs


0.0.6
-----

- Added stop_on_error attribute to raise a StopTest exception when a step fails
- Allow execution of arbitrary Selenium::Client::Driver methods
- Separated support methods from SeleniumTest methods
- Fixed field_contains and field_equals so they fail when a field doesn't exist


0.0.5
-----

- Allow Selenium-style locators beginning with id=, name=, xpath=, css= etc.
- Raise a StopTest exception when Selenium is not running
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

