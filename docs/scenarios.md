Scenarios
=========

When writing test scripts in FitNesse, it's likely that you'll have certain
steps repeated in several places. For instance, if your website has a user
login feature, logging into the site may be something you need to do at the
beginning of each script. One way to encapsulate these steps is by writing a
[custom step](custom.md) that accepts the username and password as parameters.
Another way is to use a [Scenario table](http://fitnesse.org/FitNesse.UserGuide.SliM.ScenarioTable),
which lets you define the sub-steps directly in your FitNesse wiki.

Here is a sample Scenario table for logging in:

    | scenario | Login with username _ and password _ | username, password |
    | Fill in | Username | with | @username |
    | Fill in | Password | with | @password |
    | Press | Login |
    | Page loads in | 10 | seconds or less |
    | See | Login successful |

This Scenario table accepts `username` and `password` parameters; the `@`
prefix causes the parameter values to be expanded within the table. To call
this Scenario from a Script table:

    | script | selenium test | http://www.example.com |
    | Open browser |
    | Login with username Administrator and password LetMeIn |

For maximum reusability, you may want to create a wiki page (or several)
dedicated to helper scenarios, which can be included by the pages that use
them. For example, given this page hierarchy:

- `MyTests`
    - `SetUp`
    - `HelperScenarios`
    - `TestOne`
    - `TestTwo`

If your Scenario table is in `HelperScenarios`, and `TestOne` and `TestTwo`
both need to call the Login scenario, put this line at the top of `TestOne`
and `TestTwo`:

    !include HelperScenarios

When executing any Script that includes Scenarios, the steps of that scenario
are expanded within the results table, so you can see the status of all
sub-steps. It's possible to nest scenarios within scenarios, to build more
complex steps out of simpler ones.

Next: [Development](development.md)

