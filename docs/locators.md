Locators
========

By default, Selenium accepts a [variety of locator strings](http://release.seleniumhq.org/selenium-remote-control/0.9.2/doc/dotnet/Selenium.html)
for specifying the element you want to inspect or interact with. While these
are suitable for programmers and web developers with intimate knowledge of
their webpages' structure, they are often not intuitive to the average user.

For example, the default behavior of Selenium is to match elements based on
their `name` attribute. Given this HTML:

    <a name="contact_us_link" href="/contact">Contact Us</a>

To click on the "Contact Us" link using a standard Selenium locator, you'd have
to do one of the following:

    click "contact_us_link"
    click "link=Contact Us"

Or in FitNesse:

    | Click | contact_us_link |
    | Click | link=Contact Us |

This is easy enough, but what if the target element does not have a `name`
attribute defined? What if the link is an image instead of a piece of text? In
those cases, you'd have to use a locator string based on `id` (if the element
has one), `dom`, `xpath`, or `css`. Again, all of these are
programmer-oriented, and would not make much sense to the average user looking
at the webpage. While this scheme allows selecting HTML elements with great
precision, it can become cumbersome to read and write.

The situation becomes even more complex with HTML form elements--text fields,
dropdowns, checkboxes and the like. While HTML provides a way to semantically
label these fields, Selenium provides no way to select those fields based on
their label, aside from using a rather long and complex `xpath` expression.
For instance, given this HTML:

    <label for="first_name_text_field">First name</label>
    <input id="first_name_text_field" type="text" />

With Selenium's default selectors, you could do:

    type "id=first_name_text_field", "Eric"
    type "xpath=.//input[@id = ../label[.='First name']/@for]", "Eric"

In FitNesse:

    | type | id=first_name_text_field | Eric |
    | type | xpath=.//input[@id = ../label[.='First name']/@for] | Eric |

Neither of these solutions is very attractive.

For these reasons, Rsel has a simpler locator scheme that matches elements
based on several likely attributes. Links are matched on `id`, link text, or
the `alt` text in the case of an image link. Form fields are matched on their
plain-text label, `name` or `id` attribute. In Rsel, the above examples become
much easier:

    click "Contact Us"
    type_into_field "Eric", "First name"

Or in FitNesse:

    | Click | Contact Us |
    | Type | Eric | into field | First name |

This allows you to use human-readable locator strings for most HTML elements,
keeping your test steps free of ugly markup. Refer to the `SeleniumTest` method
documentation for details on what locator strings are expected for each element.

If you like, you can still pass explicit Selenium-style locators, as long as
they are prefixed with `id=`, `name=`, `dom=`, `xpath=`, `link=`, or `css=`. If
you do this, it's up to you to make sure you're using a suitable locator for
the kind of element you're interacting with. For example, it doesn't make much
sense to write:

    | Type | Eric | into field | link=Contact Us |

But Rsel won't stop you from trying! One drawback to using explicit Selenium
locators is that any [scoping](scoping.md) clause is ignored. In most cases,
it's easier, safer, and more readable to use the plain text locator, and rely
on Rsel's internal logic to find the correct element. This feature is only
provided as a workaround for the possibility that Rsel's locator scheme is too
restrictive for your needs.

Next: [Scoping](scoping.md)

