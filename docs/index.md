RSel
====

RSel connects [FitNesse](http://fitnesse.org) to
[Selenium](http://seleniumhq.org) via [Ruby](http://ruby-lang.org). It allows
you to use a natural English syntax to write web application tests.

Here's an example of a simple test:

    !| script | selenium test | http://www.google.com    |
    | Open browser                                       |
    | Visit      | http://www.google.com                 |
    | Should see | About Google                          |
    | Type       | Selenium      | into | Search | field |
    | Click      | Google Search | button                |
    | Pause      | 5             | seconds               |
    | Close browser                                      |


