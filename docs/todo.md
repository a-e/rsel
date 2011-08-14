To-do list
----------

- Pass better error messages back to FitNesse. It seems that Slim script tables
  only support true/false results, with no clear way to report on what went
  wrong (aside from raising an exception, which even then curiously does not
  mark the step as failed)
- Verify the presence of images, allow clicking on images
- Create a Selenium IDE plugin to generate FitNesse-formatted output for
  recorded scripts
- Avoid page-latency issues by automatically waiting for requests to finish.
  Don't make the user insert wait-for-load / pause-seconds steps everywhere.
- Add documentation for non-FitNesse usage
- Possibly add a wrapper for selenium-server, so users can easily get started
  without manually downloading selenium-server.jar and starting it up

Next: [History](history.md)
