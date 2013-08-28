# [v2.1.1](https://github.com/timcraft/formeze/tree/v2.1.1) (2013-08-28)

  * Fixed that custom validation should not execute for optional fields
    with blank values

# [v2.1.0](https://github.com/timcraft/formeze/tree/v2.1.0) (2013-08-27)

  * Fixed that custom validation should only execute when there are no
    existing errors on the associated field

  * Removed :word_limit field option

# [v2.0.0](https://github.com/timcraft/formeze/tree/v2.0.0) (2013-06-10)

  * Added new custom validation functionality

  * Removed existing (undocumented) custom validation functionality

  * KeyError now includes an error message when raised for unexpected keys

  * Added #to_h form instance method

  * Removed :char_limit field option

  * Deprecated :word_limit field option (use custom validation instead)

# [v1.9.1](https://github.com/timcraft/formeze/tree/v1.9.1) (2013-01-06)

  * Added :minlength field option

  * Added :maxlength field option

  * Deprecated :char_limit field option (use :maxlength instead)

# [v1.9.0](https://github.com/timcraft/formeze/tree/v1.9.0) (2012-11-22)

  * Added :blank field option for specifying a null object to be used in place of blank input

# [v1.8.0](https://github.com/timcraft/formeze/tree/v1.8.0) (2012-11-16)

  * Added #fill instance method

  * Improved handling of Rails utf8/authenticity_token parameters

# [v1.7.0](https://github.com/timcraft/formeze/tree/v1.7.0) (2012-11-13)

  * Ruby 1.8.7 compatibility

  * Renamed Formeze::UserError to Formeze::ValidationError

  * Added #to_hash instance method

# [v1.6.0](https://github.com/timcraft/formeze/tree/v1.6.0) (2012-10-25)

  * Added #errors_on? instance method for checking if there are errors on a specific field

  * Added #errors_on instance method for accessing the errors on a specific field

  * Added parse class method, so instead of this:

        form = ExampleForm.new
        form.parse(request.raw_post)

    You can now do this:

        form = ExampleForm.parse(request.raw_post)

# [v1.5.1](https://github.com/timcraft/formeze/tree/v1.5.1) (2012-10-22)

  * Added Formeze::Form class, so forms can now be defined like this:

        class ExampleForm < Formeze::Form
        end

    The previous style of setup is still supported:

        class ExampleForm < SomeAncestorClass
          Formeze.setup(self)
        end

# [v1.5.0](https://github.com/timcraft/formeze/tree/v1.5.0) (2012-10-08)

  * Added #errors? instance method

  * Added Formeze.scrub method so that the scrub methods can be re-used outside field validation

# [v1.4.0](https://github.com/timcraft/formeze/tree/v1.4.0) (2012-08-21)

  * Added :scrub field option for cleaning up input data before validation

# [v1.3.0](https://github.com/timcraft/formeze/tree/v1.3.0) (2012-08-21)

  * Added functionality for overriding error messages via i18n

  * Added functionality for setting field labels globally via i18n

# [v1.2.0](https://github.com/timcraft/formeze/tree/v1.2.0) (2012-05-14)

  * Replaced experimental guard/halting functionality with :defined_if and :defined_unless field options

# [v1.1.3](https://github.com/timcraft/formeze/tree/v1.1.3) (2012-04-10)

  * Fixed early return from guard/halting conditions

# [v1.1.2](https://github.com/timcraft/formeze/tree/v1.1.2) (2012-04-09)

  * Fixed validation so that additional checks are skipped if the input is blank

# [v1.1.1](https://github.com/timcraft/formeze/tree/v1.1.1) (2012-04-09)

  * Added an error message for Formeze::KeyError exceptions

# [v1.1.0](https://github.com/timcraft/formeze/tree/v1.1.0) (2012-04-09)

  * Changed behaviour of experimental guard conditions and added halting conditions with opposite behaviour

# [v1.0.0](https://github.com/timcraft/formeze/tree/v1.0.0) (2012-04-09)

  * First version!
