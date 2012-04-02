Studying
========

What is studying?
-----------------
Studying is looking at some material to recall it more easily later.  No,
really!  In this case, studying refers to a process that sends the entire web
page from the browser to the Rsel server for further analysis.  The name is
based on Perl's `study` command.

Why would I want to study?  (I'm not in school anymore!)
--------------------------------------------------------
The main reason for studying is that Internet Explorer works with pages, and
xpaths in particular, very slowly.  It so happens that the xpaths sent by
normal Rsel commands are particularly slow to process.  Studying can make your
test run five times as fast or more!

Wow!  What's the catch?
-----------------------
The catch is that when you study, you may not be aware of what's going on
around you.  While studying, if the page changes on the web browser, you often
won't see those changes.  This can lead to failed identification of controls,
or worse, misidentifications.

The other, minor catch is that you could wind up spending more time sending
data (entire web pages) than you save by studying.

Alright, I'll be careful.  How do I use studying?
-------------------------------------------------
There are two ways, the easy way and the efficient way.  The efficient way is
to identify blocks where you are doing a lot of work on one page, but the HTML
content of a page won't change.  Then place a `begin_study` call before the
block, and an `end_study` call after it.

What happens if I forget about end_study?
-----------------------------------------
Don't worry: studying is smart enough to notice certain commands that indicate
major page changes, such as `page_loads_in_seconds_or_less` and
`see_within_seconds`.  Of course, this could also lead to your study blocks
ending before you expect them to, but such commands almost always mean a study
block should end.

That's nice, but adding all those blocks sounds like a pain.  What's the easy way?
----------------------------------------------------------------------------------
The easy way is to set a minimum number of fields which, when worked with at
once, will be studied before the work starts.  You do this with either the
`study` option when initializing Rsel or with the `set_fields_study_min`
command within Rsel.  Zero, the default, means to never study.  Setting the
value to 10, for instance, would mean that when one command works with 10 or
more different fields at once, a study would happen before the work begins.
Right now, only the `set_fields` and `fields_equal` classes of commands can
work with so many different fields at once.

What if I set set_fields_study_min to 1?  Does it...study for every command?
----------------------------------------------------------------------------
Almost.  Along with the set_fields and fields_equal commands mentioned above,
every command that uses an xpath of 100 characters or more gets studied.  (This
bit is currently hard-coded; I may modify it in future versions.)  Some
commands are also known not to affect the page text, like `see` or `get_text`.
These do not trigger re-studying for the next command.  Even if
`set_fields_study_min` is greater than 1, commands after a `fields_equal` may
also benefit from the studying done in that command.

Too long; didn't read.  Can't I just say "go fast" or something?
----------------------------------------------------------------
Pretty much.  Add the `study:auto` value to the Rsel initialization hash.

Sweet, most of my tests are fast on IE!  But some now fail.
-----------------------------------------------------------
Auto-studying works very hard to be transparent and invisible, but rarely it
fails.  For sections like this, you can turn off studying with
`set_fields_study_min(0)` or `set_fields_study_min('never')`.  You can later go
back to what you set in the initialization with
`set_fields_study_min('default')`.

Next: [Examples](examples.md)
