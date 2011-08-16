Usage
=====

Rsel was originally designed for use with [FitNesse](http://fitnesse.org)
script tables, but it works just as well without FitNesse. This page describes
the basic principles of using Rsel in a Ruby script. If you plan to use Rsel
through FitNesse, you can skip to [FitNesse](fitnesse.md).

Here is a simple example of a Ruby script that uses Rsel to login to a website:

    require 'rubygems'
    require 'rsel/selenium_test'

    # Custom test class
    class MyTest < SeleniumTest
      def login
        visit "/login"
        fill_in_with "Username", "admin"
        fill_in_with "Password", "B4tM4n"
        press "Log in"
      end
    end

    # The "main" program
    if __FILE__ == $0
      st = MyTest.new("http://my.site.com")
      st.open_browser
      st.login
      st.close_browser
    end

The `SeleniumTest` class is the main API to Rsel, handling all browser actions
that you might want to do. Overriding it allows you to define custom actions,
built upon the ones already provided.

When you instantiate a `SeleniumTest`, you need to pass a URL. This is the URL
of the website you are testing; in this example, we're logging into
`http://my.site.com`. By default, `SeleniumTest` assumes your Selenium Server
is running on `localhost` port `4444`; if your Selenium Server is running
elsewhere, just provide the host and port to the `SeleniumTest` (in this case,
`MyTest`) constructor:

    st = MyTest.new("http://my.site.com", :host => 'my.selenium.host', :port => '4445')

The next step, `open_browser`, is very important. This is what starts up the web
browser, connects to the test system's URL, and executes all further actions.

After opening the browser, you can call any of the methods `SeleniumTest`
provides, or any custom ones you have defined in your `MyTest` derived class.
When you're done, use `close_browser` to end the session.

See the `SeleniumTest` class documentation for a full list of available methods
and how to use them.

Next: [FitNesse](fitnesse.md)

