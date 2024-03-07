# 4.2.0

* Fixed file validation for e.g. `.md` files sent as application/octet-stream

* Fixed file validation for e.g. `.rtf` files sent as text/rtf

# 4.1.0

* Fixed compatibility with rack 3+

# 4.0.1

* Fixed outdated changelog_uri

# 4.0.0

* Removed support for older rubies. **Required ruby version is now 2.4.0**

* Changed the code to use keyword arguments for options

* Renamed the `when` validation option to `if`

# 3.1.0

* Added `'commit'` to the list of Rails form keys to ignore (#4)

* Added frozen string literal comment

* Extracted private constants to reduce memory allocations

* Removed spec file from gem

# 3.0.0

* Added functionality for handling multipart form data. For example:

      class ExampleForm < Formeze::Form
        field :image, accept: 'image/jpg,image/png', maxsize: 1000
      end

  For this to work the request needs to be passed to the parse method:

      ExampleForm.new.parse(request)

* Removed the deprecated parse class method

* Removed Ruby 1.8.7 compatibility

# 2.2.0

* The #fill and #parse instance methods now return self. So instead of this:

      form = ExampleForm.new
      form.parse(request.raw_post)

  You can now do this:

      form = ExampleForm.new.parse(request.raw_post)

* Deprecated the parse class method

# 2.1.1

* Fixed that custom validation should not execute for optional fields with blank values

# 2.1.0

* Fixed that custom validation should only execute when there are no existing errors on the associated field

* Removed `:word_limit` field option

# 2.0.0

* Added new custom validation functionality

* Removed existing (undocumented) custom validation functionality

* KeyError now includes an error message when raised for unexpected keys

* Added #to_h form instance method

* Removed `:char_limit` field option

* Deprecated `:word_limit` field option (use custom validation instead)

# 1.9.1

* Added `:minlength` field option

* Added `:maxlength` field option

* Deprecated `:char_limit` field option (use `:maxlength` instead)

# 1.9.0

* Added `:blank` field option for specifying a null object to be used in place of blank input

# 1.8.0

* Added #fill instance method

* Improved handling of Rails utf8/authenticity_token parameters

# 1.7.0

* Ruby 1.8.7 compatibility

* Renamed `Formeze::UserError` to `Formeze::ValidationError`

* Added #to_hash instance method

# 1.6.0

* Added #errors_on? instance method for checking if there are errors on a specific field

* Added #errors_on instance method for accessing the errors on a specific field

* Added parse class method, so instead of this:

      form = ExampleForm.new
      form.parse(request.raw_post)

  You can now do this:

      form = ExampleForm.parse(request.raw_post)

# 1.5.1

* Added `Formeze::Form` class, so forms can now be defined like this:

      class ExampleForm < Formeze::Form
      end

  The previous style of setup is still supported:

      class ExampleForm < SomeAncestorClass
        Formeze.setup(self)
      end

# 1.5.0

* Added #errors? instance method

* Added `Formeze.scrub` method so that the scrub methods can be re-used outside field validation

# 1.4.0

* Added `:scrub` field option for cleaning up input data before validation

# 1.3.0

* Added functionality for overriding error messages via i18n

* Added functionality for setting field labels globally via i18n

# 1.2.0

* Replaced experimental guard/halting functionality with `:defined_if` and `:defined_unless` field options

# 1.1.3

* Fixed early return from guard/halting conditions

# 1.1.2

* Fixed validation so that additional checks are skipped if the input is blank

# 1.1.1

* Added an error message for `Formeze::KeyError` exceptions

# 1.1.0

* Changed behaviour of experimental guard conditions and added halting conditions with opposite behaviour

# 1.0.0

* First version!
