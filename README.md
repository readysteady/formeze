Formeze: A little library for defining classes to handle form data/input
========================================================================


Motivation
----------

Most web apps built for end users will need to process urlencoded form data.
Registration forms, profile forms, checkout forms, contact forms, and forms
for adding/editing application specific data. As developers we would like to
process this data safely, to minimise the possibility of security holes
within our application that could be exploited. Formeze adopts the approach
of being "strict by default", forcing the application code to be explicit in
what it accepts as input.


Example usage
-------------

Forms are just "plain old ruby objects". Calling `Formeze.setup` will include
some class methods and instance methods, but will otherwise leave the object
untouched (i.e. you can define your own initialization). Here is a minimal
example, which defines a form with a single "title" field:

    class ExampleForm
      Formeze.setup(self)

      field :title
    end


This form can then be used to parse and validate form/input data as follows:

    form = ExampleForm.new

    form.parse('title=Title')

    form.title  # => "Title"


Detecting errors
----------------

Formeze distinguishes between user errors (which are expected in the normal
running of your application), and key/value errors (which most likely indicate
either developer error, or form tampering).

For the latter case, the `parse` method that formeze provides will raise a
Formeze::KeyError or a Formeze::ValueError exception if the structure of the
form data does not match the field definitions.

After calling `parse` you can check that the form is valid by calling the
`#valid?` method. If it isn't you can call the `errors` method which will
return an array of error messages to display to the user.


Field options
-------------

By default fields cannot be blank, they are limited to 64 characters,
and they cannot contain newlines. These restrictions can be overrided
by setting various field options.

Defining a field without any options works well for a simple text input.
If the default character limit is too big or too small you can override
it by setting the `char_limit` option. For example:

    field :title, char_limit: 200


If you are dealing with textareas (i.e. multiple lines of text) then you can
set the `multiline` option to allow newlines. For example:

    field :description, char_limit: 500, multiline: true


Error messages will include the field label, which by default is set to the
field name, capitalized, and with underscores replace by spaces. If you want
to override this, set the `label` option. For example:

    field :twitter, label: 'Twitter Username'


If you want to validate that the field value matches a specific pattern you
can specify the `pattern` option. This is useful for validating things with
well defined formats, like numbers. For example:

    field :number, pattern: /\A[1-9]\d*\z/

    field :card_security_code, char_limit: 5, value: /\A\d+\z/


If you want to validate that the field value belongs to a set of predefined
values then you can specify the `values` option. This is useful for dealing
with input from select boxes, where the values are known upfront. For example:

    field :card_expiry_month, values: (1..12).map(&:to_s)


The `values` option is also useful for checkboxes. Specify the `key_required`
option to handle the case where the checkbox is unchecked. For example:

    field :accept_terms, values: %w(true), key_required: false


Sometimes you'll have a field with multiple values. A multiple select input,
a set of checkboxes. For this case you can specify the `multiple` option to
allow multiple values. For example:

    field :colour, multiple: true, values: Colour.keys


Unlike all the other examples so far, reading the attribute that corresponds
to this field will return an array of strings instead of a single string.


Rails usage
-----------

This is the basic pattern for using a formeze form in a rails controller:

    form = SomeForm.new
    form.parse(request.raw_post)

    if form.valid?
      # do something with form data
    else
      # display form.errors to user
    end


Formeze will automatically define optional "utf8" and "authenticity_token"
fields on every form so that you don't have to specify those manually.
