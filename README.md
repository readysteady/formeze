formeze
=======


A little Ruby library for handling form data/input.


Motivation
----------

Most web apps built for end users will need to process url-encoded form data.
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

Here is a minimal example, which defines a form with a single field:

```ruby
class ExampleForm < Formeze::Form
  field :title
end
```

This form class can then be used to parse and validate input data from
within a rails or sinatra action like this:

```ruby
form = SomeForm.new.parse(request)

if form.valid?
  # do something with form data
else
  # display form.errors to user
end
```

Formeze will automatically ignore the "utf8" and "authenticity_token"
parameters that Rails uses.

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


Validation errors
-----------------

Formeze distinguishes between validation errors (which are expected in the
normal running of your application), and key/value errors (which most likely
indicate either developer error, or form tampering). For the latter case,
the `parse` method that formeze provides will raise a `Formeze::KeyError`
or a `Formeze::ValueError` exception if the structure of the form data
does not match the field definitions.

After calling `parse` you can check that the form is valid by calling the
`#valid?` method. If it isn't you can call the `errors` method which will
return an array of error messages to display to the end user. You can also
use `errors_on?` and `errors_on` to check for and select error messages
specific to a single field.


Field options
-------------

By default fields cannot be blank, they are limited to 64 characters,
and they cannot contain newlines. These restrictions can be overridden
by setting various field options.

Defining a field without any options works well for a simple text input.
If the default length limit is too big or too small you can override it
by setting the `maxlength` option. For example:

```ruby
field :title, maxlength: 200
```

Similarly there is a `minlength` option for validating fields that should
have a minimum number of characters (e.g. passwords).

Fields are required by default. Specify the `required` option if the field
is not required, i.e. the value of the field can be blank/empty. For example:

```ruby
field :title, required: false
```

You might want to return a different value for blank fields, such as nil,
zero, or a "null" object. Use the `blank` option to specify this behaviour.
For example:

```ruby
field :title, required: false, blank: nil
```

If you are dealing with textareas (i.e. multiple lines of text) then you can
set the `multiline` option to allow newlines. For example:

```ruby
field :description, maxlength: 500, multiline: true
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

field :card_security_code, maxlength: 5, pattern: /\A\d+\z/
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

Sometimes you'll have a field with multiple values, such as a multiple select
input, or a set of checkboxes. For this case you can specify the `multiple`
option to allow multiple values. For example:

```ruby
field :colour, multiple: true, values: Colour.keys
```

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
easy for us to process. The `scrub` option can be used to specify methods for
"cleaning" input data before validation. For example:

```ruby
field :postcode, scrub: [:strip, :squeeze, :upcase]
```

The input for this field will have leading/trailing whitespace stripped,
double (or more) spaces squeezed, and the result upcased automatically.
Custom scrub methods can be defined by adding a symbol/proc entry to the
`Formeze.scrub_methods` hash.


Multipart form data
-------------------

For file fields you can specify the accept and maxsize options, for example:

```ruby
class ExampleForm < Formeze::Form
  field :image, accept: 'image/jpg,image/png', maxsize: 1000
end
```

For this to work you need to make sure your application includes the
[mime-types gem](https://rubygems.org/gems/mime-types), and that the
form is submitted with the multipart/form-data mime type.


Custom validation
-----------------

You may need additional validation logic beyond what the field options
described above provide, such as validating the format of a field without
using a regular expression, validating that two fields are equal etc.
This can be accomplished using the `validates` class method. Pass the
name of the field to be validated, and a block/proc that encapsulates
the validation logic. For example:

```ruby
class ExampleForm < Formeze::Form
  field :email

  validates :email, &EmailAddress.method(:valid?)
end
```

If the block/proc takes no arguments then it will be evaluated in the
scope of the form instance, which gives you access to the values of other
fields (and methods defined on the form). For example:

```ruby
class ExampleForm < Formeze::Form
  field :password
  field :password_confirmation

  validates :password_confirmation do
    password_confirmation == password
  end
end
```

Specify the `when` option with a proc to peform the validation conditionally.
Similar to the `defined_if` and `defined_unless` field options, the proc is
evaluated in the scope of the form instance. For example:

```ruby
class ExampleForm < Formeze::Form
  field :business_name, :defined_if => :business_account?
  field :vat_number, :defined_if => :business_account?

  validates :vat_number, :when => :business_account? do
    # ...
  end

  def initialize(account)
    @account = account
  end

  def business_account?
    @account.business?
  end
end
```

Specify the `error` option with a symbol to control which error the validation
generates. The I18n integration described below can be used to specify the
error message used, both for errors that are explicitly specified using this
option, and the default "invalid" error. For example:

```ruby
class ExampleForm < Formeze::Form
  field :email
  field :password
  field :password_confirmation

  validates :email, &EmailAddress.method(:valid?)

  validates :password_confirmation, :error => :does_not_match do
    password_confirmation == password
  end
end
```

The error for the email field validation would include the value of the
`formeze.errors.invalid` I18n key, defaulting to "is invalid" if the I18n
key does not exist. The error for the password_confirmation field validation
would include the value of the `formeze.errors.does_not_match` I18n key.


I18n integration
----------------

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
