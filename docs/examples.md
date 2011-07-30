Examples
========

This page presents some example Rsel tests, illustrating how you might use many
of the built-in methods from a FitNesse wiki page. All of these are based on
the example web application that you can find in the Rsel `test` directory;
it's the same one used for running the spec tests in the `spec` directory. See
[Development](development.md) for instructions on running the server if you'd
like to execute these examples.


Links
-------------

    | script | selenium test | !-http://localhost:8070-! |
    | Open browser |
    | Maximize browser |
    | Visit | / |
    | See | Welcome |
    | See | This is a Sinatra webapp for unit testing Rsel |
    | Link | About this site | exists |
    | Click link | About this site |
    | See | This site is really cool |
    | See title | About this site |
    | Click back |
    | See | This is a Sinatra webapp for unit testing Rsel |
    | Do not see | This site is really cool |
    | Close browser |



Buttons
-------------

    | script | selenium test | !-http://localhost:8070-! |
    | Open browser |
    | Maximize browser |
    | Visit | /form |
    | Button | Submit person form | exists |
    | Click | Submit person form | button |
    | See | We appreciate your feedback |
    | Visit | /form |
    | Button | Submit spouse form | exists | !{within:spouse_form} |
    | Click | Submit spouse form | button | !{within:spouse_form} |
    | See | We appreciate your feedback |
    | Close browser |


Checkboxes
-------------

    | script | selenium test | !-http://localhost:8070-! |
    | Open browser |
    | Maximize browser |
    | Visit | /form |
    | Enable | I like cheese | checkbox |
    | Checkbox | I like cheese | is enabled |
    | Disable | I like cheese | checkbox |
    | Checkbox | I like cheese | is disabled |
    | Enable | I like salami | checkbox | !{within:salami_checkbox} |
    | Checkbox | I like salami | is enabled | !{within:salami_checkbox} |
    | Disable | I like salami | checkbox | !{within:salami_checkbox} |
    | Checkbox | I like salami | is disabled | !{within:salami_checkbox} |
    | Close browser |


Dropdowns
-------------

    | script | selenium test | !-http://localhost:8070-! |
    | Open browser |
    | Maximize browser |
    | Visit | /form |
    | Dropdown | Height | includes | Short |
    | Dropdown | Height | includes | Average |
    | Dropdown | Height | includes | Tall |
    | Select | Tall | from | Height | dropdown |
    | Dropdown | Height | equals | Tall |
    | Select | Short | from | Height | dropdown |
    | Dropdown | Height | equals | Short |
    | Close browser |


Radiobuttons
-------------

    | script | selenium test | !-http://localhost:8070-! |
    | Open browser |
    | Maximize browser |
    | Visit | /form |
    | Select | Briefs | radio |
    | Radio | Briefs | is enabled |
    | Radio | Boxers | is disabled |
    | Select | Boxers | radio | !{within:clothing} |
    | Radio | Boxers | is enabled | !{within:clothing} |
    | Radio | Briefs | is disabled | !{within:clothing} |
    | Close browser |


Tables
-------------

    | script | selenium test | !-http://localhost:8070-! |
    | Open browser |
    | Maximize browser |
    | Visit | /table |
    | Row | First name, Last name, Email, Actions | exists |
    | Row | !-Eric, Pierce, epierce@example.com-! | exists |
    | Enable | Like | checkbox | !{in_row:Marcus} |
    | Checkbox | Like | is enabled | !{in_row:Marcus} |
    | Disable | Like | checkbox | !{in_row:Marcus} |
    | Checkbox | Like | is disabled | !{in_row:Marcus} |
    | Select | Male | from | Gender | dropdown | !{in_row:Eric} |
    | Click | Edit | link | !{in_row:Eric} |
    | See title | Editing Eric |
    | Close browser |


Next: [Customization](custom.md)
