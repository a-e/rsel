Customization
-------------

When you are using Rsel through FitNesse, you may find yourself needing more
high-level steps; it can be tedious to spell out every action using the basic
actions provided by the `SeleniumTest` class.

It's pretty easy to create custom steps by subclassing `SeleniumTest` and
adding your own methods to it. Create a sibling directory to your
`FitNesseRoot`, named something like `custom_rsel`, then create a Ruby file in
there. The Ruby file can be called whatever you want--it's most logical to name
it after your application:

- `FitNesseRoot`
- `custom_rsel`
  - `my_app_test.rb`

Inside `my_app_test.rb`, you must define a module named after the folder, and a
class named after the file. You'll also need to include some `require` statements
to make sure `rsel/selenium` gets loaded. In this case, it should be:

    require `rubygems`            # If you installed Rsel from a gem
    require `rsel/selenium_test`  # Makes the SeleniumTest class available

    module CustomRsel
      class MyAppTest < Rsel::SeleniumTest
        # Custom methods go here
      end
    end

Inside your custom class, you can define any methods you want, and you can call
any of the methods defined in the `Rsel::SeleniumTest` class. For example,
let's say the login process for your application consists of three steps:

    | Fill in | Username | with | admin   |
    | Fill in | Password | with | letmein |
    | Press   | Login                     |

If you're logging in a lot, you may want a single-step login method. Here's how
you might define one:

    module CustomRsel
      class MyAppTest < Rsel::SeleniumTest

        # Login with the given username and password
        #
        # Example:
        #   | Login as | admin | with password | letmein |
        #
        def login_as_with_password(username, password)
          fill_in_with("Username", username)
          fill_in_with("Password", password)
          press("Login")
        end

      end
    end

In your FitNesse `SetUp` page, rather than (or in addition to) importing the `Rsel` module,
import your custom module:

    !| import    |
    | CustomRsel |

Note that this name must match the `module` line in your Ruby file, and the
folder where your Ruby file resides must be the lowercase_and_underscore
version of that same module name. Finally, in your actual test table, instead of:

    | script | selenium test | ... |

You'll use:

    | script | my app test | ... |

This will ensure that the `MyAppTest` class will be used for evaluating the
steps contained in that table.

It's worth noting that the `SeleniumTest` class (and hence any derived classes)
have a `@browser` attribute referring to the underlying `Selenium::Client::Driver`
instance, which includes
[a wealth of methods](http://rdoc.info/github/ph7/selenium-client/master/Selenium/Client/Driver)
for interacting with webpages and performing verifications. If `SeleniumTest`
itself does not provide the methods you need, you can use the `@browser`
attribute directly.

Next: [Scenarios](scenarios.md)

