Installation
============

To install Rsel from a gem:

    $ gem install rsel

If you have the following test hierarchy:

- `FitNesseRoot`
  - `SeleniumTests`
    - `SetUp`
    - `LoginTest`

You should define the requisite `rubyslim` options in the `SeleniumTests` page content:

    !define TEST_SYSTEM {slim}
    !define TEST_RUNNER {rubyslim}
    !define COMMAND_PATTERN {rubyslim}

If you're using Bundler, you may need to use:

    !define TEST_SYSTEM {slim}
    !define TEST_RUNNER {bundle exec rubyslim}
    !define COMMAND_PATTERN {bundle exec rubyslim}

Finally, put this in your `SeleniumTests.SetUp` page:

    !| import |
    | Rsel    |

Next: [Usage](usage.md)

