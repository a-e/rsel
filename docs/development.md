Development
===========

If you would like to contribute to development of Rsel, create a fork of the
[Github repository](https://github.com/a-e/rsel), clone your fork, and submit
pull requests for any improvements you would like to share.


Prerequisites
-------------

Before developing and testing Rsel, you will need to install some dependencies.
Most of these will be handled by simply running:

    $ bundle install

from the git clone of Rsel. The nokogiri gem is known to fail if certain XML
development headers are missing; if you encounter this, try:

    $ sudo apt-get install libxml2-dev libxslt-dev

Then re-run `bundle install`. If this still fails, or if you're on a non-Debian OS,
consult the nokogiri
[installation instructions](http://nokogiri.org/tutorials/installing_nokogiri.html).

Aside from gem dependencies, you will need to have Java installed in order to
run the Selenium server provided with Rsel (in the `test/server` directory).
Startup of the server is handled automatically by the Rake tasks during
testing; see below.


Testing
-------

While developing, you should run the RSpec tests frequently to ensure nothing
gets broken. You can do this with a single `rake` command:

    $ rake test

This will do the following:

- Download an official selenium-server `.jar` into `test/server` (if needed)
- Start the Sinatra test application (code in `test/app.rb` and `test/views/*.erb`)
- Start the Selenium server (the `.jar` file in `test/server`)
- Run RSpec
- Stop the Selenium server
- Stop the Sinatra test application

Since there's a large startup cost associated with all of this (in particular
the Selenium server), when running frequent tests you may want to start those
up and keep them running. There are rake tasks for that also:

    $ rake servers:start

Now do:

    $ rake spec

as many times as you want. When you're done, manually stop the servers:

    $ rake servers:stop

You can also start the Selenium and Sinatra testapp servers individually:

    $ rake selenium:rc:start
    $ rake testapp:start

and stop them:

    $ rake selenium:rc:stop
    $ rake testapp:stop

When the test application is running, you can view the site in your browser by
visiting http://localhost:8070/. If you are developing new features, please add
spec tests in the `spec` directory!

Next: [To-do list](todo.md)
