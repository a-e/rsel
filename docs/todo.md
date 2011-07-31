To-do list
----------

- Pass better error messages back to FitNesse. It seems that Slim script tables
  only support true/false results, with no clear way to report on what went
  wrong (aside from raising an exception, which even then curiously does not
  mark the step as failed)
- Find a way to abort a test if a step fails (will probably require more
  hacking on rubyslim)
- Verify the presence of images, allow clicking on images
- Create a Selenium IDE plugin to generate FitNesse-formatted output for
  recorded scripts

Next: [History](history.md)
