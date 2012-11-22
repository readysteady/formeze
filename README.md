Formeze: A little library for handling form data/input
======================================================


Motivation
----------

Most web apps built for end users will need to process urlencoded form data.
Registration forms, profile forms, checkout forms, contact forms, and forms
for adding/editing application specific data. As developers we would like to
process this data safely, to minimise the possibility of security holes
within our application that could be exploited. Formeze adopts the approach
of being "strict by default", forcing the application code to be explicit in
what it accepts as input.


Installation
------------

```
$ gem install formeze
```


Example usage
-------------

Forms are just "plain old ruby objects" with added behaviour. Here is a
minimal example, which defines a form with a single "title" field:

```ruby
class ExampleForm < Formeze::Form
  field :title
end
```

This form can then be used to parse and validate input data like this:

```ruby
form = ExampleForm.new

form.parse('title=Title')

form.title  # => "Title"
```

If you prefer not to inherit from the `Formeze::Form` class then you can
instead call the `Formeze.setup` method like this:

```ruby
class ExampleForm
  Formeze.setup(self)

  field :title
end
```

Both styles of setup will include the formeze class methods and instance
methods but will otherwise leave the object untouched (i.e. you can define
your own initialization logic).


Detecting errors
----------------

Formeze distinguishes between validation errors (which are expected in the
normal running of your application), and key/value errors (which most likely
indicate either developer error, or form tampering).

For the latter case, the `parse` method that formeze provides will raise a
Formeze::KeyError or a Formeze::ValueError exception if the structure of the
form data does not match the field definitions.

After calling `parse` you can check that the form is valid by calling the
`#valid?` method. If it isn't you can call the `errors` method which will
return an array of error messages to display to the end user.

You can also use `errors_on?` and `errors_on` to check for and select error
messages specific to a single field.


Field options
-------------

By default fields cannot be blank, they are limited to 64 characters,
and they cannot contain newlines. These restrictions can be overridden
by setting various field options.

Defining a field without any options works well for a simple text input.
If the default character limit is too big or too small you can override
it by setting the `char_limit` option. For example:

```ruby
field :title, char_limit: 200
```

Specify the `required` option to make the field optional, i.e. the value
of the field can be blank/empty. For example:

```ruby
field :title, required: false
```

If you are dealing with textareas (i.e. multiple lines of text) then you can
set the `multiline` option to allow newlines. For example:

```ruby
field :description, char_limit: 500, multiline: true
```

Error messages will include the field label, which by default is set to the
field name, capitalized, and with underscores replace by spaces. If you want
to override this, set the `label` option. For example:

```ruby
field :twitter, label: 'Twitter Username'
```

If you want to validate that the field value matches a specific pattern you
can specify the `pattern` option. This is useful for validating things with
well defined formats, like numbers. For example:

```ruby
field :number, pattern: /\A[1-9]\d*\z/

field :card_security_code, char_limit: 5, pattern: /\A\d+\z/
```

If you want to validate that the field value belongs to a set of predefined
values then you can specify the `values` option. This is useful for dealing
with input from select boxes, where the values are known upfront. For example:

```ruby
field :card_expiry_month, values: (1..12).map(&:to_s)
```

The `values` option is also useful for checkboxes. Specify the `key_required`
option to handle the case where the checkbox is unchecked. For example:

```ruby
field :accept_terms, values: %w(true), key_required: false
```

Sometimes you'll have a field with multiple values. A multiple select input,
a set of checkboxes. For this case you can specify the `multiple` option to
allow multiple values. For example:

```ruby
field :colour, multiple: true, values: Colour.keys
```

Unlike all the other examples so far, reading the attribute that corresponds
to this field will return an array of strings instead of a single string.

Sometimes you'll only want the field to be defined if some condition is true.
The condition may depend on the state of other form fields, or some external
state accessible from the form object. You can do this by specifying either
the `defined_if` or `defined_unless` options with a proc. Here's an example
of using the defined_if option:

```ruby
field :business_name, defined_if: proc { @account.business? }
```

In this example the `business_name` field will only be defined and validated
for business accounts. The proc is evaluated in the context of the form object,
so has full access to instance variables and methods defined on the object.
Here's an example of using the defined_unless option:

```ruby
field :same_address, values: %w(true), key_required: false

field :billing_address_line_one, defined_unless: proc { same_address? }

def same_address?
  same_address == 'true'
end
```

In this example, the `billing_address_line_one` field will only be defined
and validated if the `same_address` checkbox is checked.

Validation errors can be a frustrating experience for end users, so ideally
we want to [be liberal in what we accept](http://en.wikipedia.org/wiki/Jon_Postel#Postel.27s_Law),
but at the same time ensuring that data is consistently formatted to make it
easy for us to process. Meet the `scrub` option, which can be used to specify
methods for "cleaning" input data before validation. For example:

```ruby
field :postcode, scrub: [:strip, :squeeze, :upcase]
```

The input for this field will have leading/trailing whitespace stripped,
double (or more) spaces squeezed, and the result upcased automatically.

In order to define a custom scrub method just add a symbol/proc entry to
the `Formeze.scrub_methods` hash.


Rails usage
-----------

This is the basic pattern for using a formeze form in a rails controller:

```ruby
form = SomeForm.new
form.parse(request.raw_post)

if form.valid?
  # do something with form data
else
  # display form.errors to user
end
```

Formeze will automatically ignore the "utf8" and "authenticity_token"
parameters that Rails uses, so you don't have to handle those manually.


Sinatra usage
-------------

Using formeze with sinatra is similar, the only difference is that there is
no raw_post method on the request object so the body has to be read directly:

```ruby
form = SomeForm.new
form.parse(request.body.read)

if form.valid?
  # do something with form data
else
  # display form.errors to user
end
```


Integration with I18n
---------------------

Formeze integrates with [I18n](http://edgeguides.rubyonrails.org/i18n.html)
so that you can define custom error messages and field labels within your
locales (useful both for localization, and when working with designers).

For example, here is how you would change the "required" error message
(which defaults to "is required"):

```yaml
# config/locales/en.yml
en:
  formeze:
    errors:
      required: "cannot be blank"
```

And here is an example of how you would set a custom label for fields named
"first_name" (for which the default label would be "First name"):

```yaml
# config/locales/en.yml
en:
  formeze:
    labels:
      first_name: "First Name"
```

Labels defined in this way apply globally to all Formeze forms, but can be
overridden using the label field option which will take precedence.
