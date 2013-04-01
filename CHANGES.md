# [v1.9.1](https://github.com/timcraft/formeze/tree/v1.9.1) (2013-01-06) [c8dbc44](https://github.com/timcraft/formeze/commit/c8dbc44762aa304eb05bcc5acb13fb735401512e)

  * Added :minlength field option

  * Added :maxlength field option

  * Deprecated :char_limit field option (use :maxlength instead)

# [v1.9.0](https://github.com/timcraft/formeze/tree/v1.9.0) (2012-11-22) [87a87b1](https://github.com/timcraft/formeze/commit/87a87b1131767fbdcf5f03b569272e4c41569b34)

  * Added :blank field option for specifying a null object to be used in place of blank input

# [v1.8.0](https://github.com/timcraft/formeze/tree/v1.8.0) (2012-11-16) [4405ec6](https://github.com/timcraft/formeze/commit/4405ec65fce8242396e9e854f3b6faa7f648be4e)

  * Added #fill instance method

  * Improved handling of Rails utf8/authenticity_token parameters

# [v1.7.0](https://github.com/timcraft/formeze/tree/v1.7.0) (2012-11-13) [5640b27](https://github.com/timcraft/formeze/commit/5640b27d934970d6d208f4ad7f49894023a6fe9b)

  * Ruby 1.8.7 compatibility

  * Renamed Formeze::UserError to Formeze::ValidationError

  * Added #to_hash instance method

# [v1.6.0](https://github.com/timcraft/formeze/tree/v1.6.0) (2012-10-25) [281a1fb](https://github.com/timcraft/formeze/commit/281a1fbabbda00e1ea3bced0309032de2f0a9d5f)

  * Added #errors_on? instance method for checking if there are errors on a specific field

  * Added #errors_on instance method for accessing the errors on a specific field

  * Added parse class method, so instead of this:

        form = ExampleForm.new
        form.parse(request.raw_post)

    You can now do this:

        form = ExampleForm.parse(request.raw_post)

# [v1.5.1](https://github.com/timcraft/formeze/tree/v1.5.1) (2012-10-22) [c0e4056](https://github.com/timcraft/formeze/commit/c0e40561021e9c0c7609aedd1a21a9654a03c6fb)

  * Added Formeze::Form class, so forms can now be defined like this:

        class ExampleForm < Formeze::Form
        end

    The previous style of setup is still supported:

        class ExampleForm < SomeAncestorClass
          Formeze.setup(self)
        end

# [v1.5.0](https://github.com/timcraft/formeze/tree/v1.5.0) (2012-10-08) [5d830be](https://github.com/timcraft/formeze/commit/5d830be73589aebc7936a0f81949e913a8e9bac2)

  * Added #errors? instance method

  * Added Formeze.scrub method so that the scrub methods can be re-used outside field validation

# [v1.4.0](https://github.com/timcraft/formeze/tree/v1.4.0) (2012-08-21) [7e724a6](https://github.com/timcraft/formeze/commit/7e724a6c13babbd1f08b43ba6af92c7bae7e2ba1)

  * Added :scrub field option for cleaning up input data before validation

# [v1.3.0](https://github.com/timcraft/formeze/tree/v1.3.0) (2012-08-21) [18d97da](https://github.com/timcraft/formeze/commit/18d97dabb82a6f1f9a1c4343180178e1cc629cd8)

  * Added functionality for overriding error messages via i18n

  * Added functionality for setting field labels globally via i18n

# [v1.2.0](https://github.com/timcraft/formeze/tree/v1.2.0) (2012-05-14) [c53b460](https://github.com/timcraft/formeze/commit/c53b460160722a74b25086de2b4829bcb34d78ab)

  * Replaced experimental guard/halting functionality with :defined_if and :defined_unless field options

# [v1.1.3](https://github.com/timcraft/formeze/tree/v1.1.3) (2012-04-10) [961d410](https://github.com/timcraft/formeze/commit/961d4108db1eefa641e13e7b162eb63d06a3ce80)

  * Fixed early return from guard/halting conditions

# [v1.1.2](https://github.com/timcraft/formeze/tree/v1.1.2) (2012-04-09) [5a8b17f](https://github.com/timcraft/formeze/commit/5a8b17fda0b542bf2f0f359812d497fea28b8867)

  * Fixed validation so that additional checks are skipped if the input is blank

# [v1.1.1](https://github.com/timcraft/formeze/tree/v1.1.1) (2012-04-09) [c2cd57c](https://github.com/timcraft/formeze/commit/c2cd57ca5d641a543bc2d5d8d12974a46216927a)

  * Added an error message for Formeze::KeyError exceptions

# [v1.1.0](https://github.com/timcraft/formeze/tree/v1.1.0) (2012-04-09) [0af6965](https://github.com/timcraft/formeze/commit/0af6965fce8a34026bd98356adc40d4ddf5cac92)

  * Changed behaviour of experimental guard conditions and added halting conditions with opposite behaviour

# [v1.0.0](https://github.com/timcraft/formeze/tree/v1.0.0) (2012-04-09) [ec2524f](https://github.com/timcraft/formeze/commit/ec2524ffa47aac87e95b4bc5b6c9a9fe4af3c95f)

  * First version!
