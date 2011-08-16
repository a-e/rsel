FitNesse
========

With FitNesse, some initial configuration steps are necessary. Assuming you
have a FitNesse wiki-page hierarchy like this:

- `FitNesseRoot`
  - `SeleniumTests`
    - `SetUp`
    - `LoginTest`

Put this in your `SeleniumTests.SetUp` page:

    !| import |
    | Rsel    |

You also need to define the requisite `rubyslim` options in the `SeleniumTests`
page content, so they will apply to all sub-wikis:

    !define TEST_SYSTEM {slim}
    !define TEST_RUNNER {rubyslim}
    !define COMMAND_PATTERN {rubyslim}

If you're using Bundler, you may need to use:

    !define TEST_SYSTEM {slim}
    !define TEST_RUNNER {bundle exec rubyslim}
    !define COMMAND_PATTERN {bundle exec rubyslim}

Once you have created your `SetUp` page, you can create sibling pages with
tests in them. For instance, continuing with the example test hierarchy above,
your `SeleniumTests.LoginTest` might look like this:

    | script | selenium test | http://www.mysite.com |
    | Open browser                                   |
    | Fill in       | Username | with | castle       |
    | Fill in       | Password | with | beckett      |
    | Click button  | Log in                         |
    | Page loads in | 5        | seconds or less     |
    | See           | Logged in as castle            |
    | Close browser                                  |

By default, the server runs on port 4444, and this is the port that Rsel uses
unless you tell it otherwise. Rsel also assumes that you're running
selenium-server on your localhost (that is, the same host where FitNesse is
running); if you need to use a different host or port number, pass those as
a hash argument to the first line of the table. For example, if you are running
selenium-server on `my.selenium.host`, port `4455`, do this:

    | script | selenium test | http://www.mysite.com | !{host:my.selenium.host, port:4455} |

Another useful argument to pass in this hash is `stop_on_error`, which causes
the test to be aborted whenever any failure occurs:

    | script | selenium test | http://www.mysite.com | !{stop_on_error:true} |

By default, when an error occurs, the failing step is simply colored red, and
the test continues. With `stop_on_error` set, an exception will be raised.

The first argument after `selenium test` is the URL of the site you will be testing.
This URL is loaded when you call `Open browser`, and all steps that follow are
assumed to stay within the same domain. You can navigate around the site by
clicking links and filling in forms just as a human user would; you can also go
directly to a specific path within the domain with the `Visit` method:

    | Visit | /some/path       |
    | Visit | /some/other/path |

These paths are evaluated relative to the domain your test is running in. (It's
theoretically possible to navigate to a different domain, but the Selenium
driver frowns upon it.)

See the `SeleniumTest` class documentation for a full list of available methods
and how to use them.

Next: [Locators](locators.md)

