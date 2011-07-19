RSel
====

RSel connects [FitNesse](http://fitnesse.org) to
[Selenium](http://seleniumhq.org) via [Ruby](http://ruby-lang.org). It allows
you to use a natural English syntax to write web application tests.


Usage
-----

If you have the following test hierarchy:

- FitNesseRoot
  - SeleniumTests
    - SetUp
    - LoginTest

You should define the requisite `rubyslim` options in the `SeleniumTests` page content:

    !define TEST_SYSTEM {slim}
    !define TEST_RUNNER {rubyslim}
    !define COMMAND_PATTERN {rubyslim}

If you're using Bundler, you may need to use:

    !define TEST_SYSTEM {slim}
    !define TEST_RUNNER {bundle exec rubyslim}
    !define COMMAND_PATTERN {bundle exec rubyslim}

Next, put this in your `SeleniumTests.SetUp` page:

    !| import |
    | Rsel    |

Finally, add your tests to subpages of `SeleniumTests`. For instance, your
`SeleniumTests.LoginTest` might look like this:

    !| script | selenium test | http://www.mysite.com |
    | Open browser                                    |
    | Fill in       | Username | with | castle        |
    | Fill in       | Password | with | beckett       |
    | Click button  | Log in                          |
    | Page loads in | 5        | seconds or less      |
    | Should see    | Logged in as castle             |
    | Close browser                                   |

The URL you provide in the first line of the table will be the default URL used
when you call `Open browser`. If you need to visit a different URL, or even a
relative path, during the course of your test, call `Visit`:

    | Visit | http://www.othersite.com |
    | Visit | /some/path               |

See the `SeleniumTest` class documentation for a full list of available methods
and how to use them.


TODO
----

- Pass better error messages back to FitNesse. It seems that Slim script tables
  only support true/false results, with no clear way to report on what went
  wrong (aside from raising an exception, which even then curiously does not
  mark the step as failed)
- Find a way to abort a test if something goes catastrophically wrong (such as
  being unable to connect to the Selenium server)


