To-do list
----------

- Pass better error messages back to FitNesse. It seems that Slim script tables
  only support true/false results, with no clear way to report on what went
  wrong (aside from raising an exception, which even then curiously does not
  mark the step as failed)
- Find a way to abort a test if something goes catastrophically wrong (such as
  being unable to connect to the Selenium server)

Some additional step methods needed:

- dropdown_includes
- dropdown_equals
- checkbox_enabled
- checkbox_disabled
- radio_enabled
- radio_disabled
