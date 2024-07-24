require 'spec_helper'

RSpec.describe 'Form with field' do
  class FormWithField < Formeze::Form
    field :title
  end

  let(:form) { FormWithField.new }

  describe '#title' do
    it 'returns nil' do
      expect(form.title).to be_nil
    end
  end

  describe '#title=' do
    it 'sets the value of the title attribute' do
      form.title = 'Untitled'

      expect(form.title).to eq('Untitled')
    end
  end

  describe '#parse' do
    it 'sets the value of the title attribute' do
      form.parse('title=Untitled')

      expect(form.title).to eq('Untitled')
    end

    it 'raises an exception when the key is missing' do
      expect { form.parse('') }.to raise_error(Formeze::KeyError)
    end

    it 'raises an exception when there are multiple values for the key' do
      expect { form.parse('title=foo&title=bar') }.to raise_error(Formeze::ValueError) { |exception|
        expect(exception.message).to eq('multiple values for title field')
      }
    end

    it 'raises an exception when the data contains unexpected keys' do
      expect { form.parse('title=Untitled&foo=bar&baz=') }.to raise_error(Formeze::KeyError) { |exception|
        expect(exception.message).to eq('unexpected form keys: baz, foo')
      }
    end

    it 'returns itself' do
      expect(form.parse('title=Untitled')).to eq(form)
    end

    context 'with rails' do
      before { Object.const_set(:Rails, Object.new) }

      it 'silently ignores the utf8, commit and authenticity_token parameters' do
        form.parse('utf8=%E2%9C%93&authenticity_token=5RMc3sPZdR%2BZz4onNS8NfK&title=Test&commit=Create')

        expect(form).not_to respond_to(:utf8)
        expect(form).not_to respond_to(:authenticity_token)
        expect(form).not_to respond_to(:commit)
        expect(form.to_hash).to eq({title: 'Test'})
      end
    end
  end

  describe '#fill' do
    it 'sets the value of the title attribute when given a hash with symbol keys' do
      form.fill({title: 'Untitled'})

      expect(form.title).to eq('Untitled')
    end

    it 'sets the value of the title attribute when given an object with a title attribute' do
      object = Object.new

      def object.title; 'Untitled' end

      form.fill(object)

      expect(form.title).to eq('Untitled')
    end

    it 'returns itself' do
      expect(form.fill({title: 'Untitled'})).to eq(form)
    end
  end

  context 'after parsing valid input' do
    before { form.parse('title=Untitled') }

    describe '#title' do
      it 'returns the value of the field' do
        expect(form.title).to eq('Untitled')
      end
    end

    describe '#valid?' do
      it 'returns true' do
        expect(form.valid?).to eq(true)
      end
    end

    describe '#errors?' do
      it 'returns false' do
        expect(form.errors?).to eq(false)
      end
    end

    describe '#errors' do
      it 'returns an empty array' do
        expect(form.errors).to eq([])
      end
    end

    describe '#errors_on?' do
      it 'returns false when given the title field name' do
        expect(form.errors_on?(:title)).to eq(false)
      end
    end

    describe '#errors_on' do
      it 'returns an empty array when given the title field name' do
        expect(form.errors_on(:title)).to eq([])
      end
    end

    describe '#to_h' do
      it 'returns a hash containing the field name and its value' do
        expect(form.to_h).to eq({title: 'Untitled'})
      end
    end

    describe '#to_hash' do
      it 'returns a hash containing the field name and its value' do
        expect(form.to_hash).to eq({title: 'Untitled'})
      end
    end
  end

  context 'after parsing blank input' do
    before { form.parse('title=') }

    describe '#valid?' do
      it 'returns false' do
        expect(form.valid?).to eq(false)
      end
    end

    describe '#errors?' do
      it 'returns true' do
        expect(form.errors?).to eq(true)
      end
    end

    describe '#errors' do
      it 'returns an array containing a single error message' do
        expect(form.errors.map(&:to_s)).to eq(['Title is required'])
      end
    end

    describe '#errors_on?' do
      it 'returns true when given the title field name' do
        expect(form.errors_on?(:title)).to eq(true)
      end
    end

    describe '#errors_on' do
      it 'returns an array containing a single error message when given the title field name' do
        expect(form.errors_on(:title).map(&:to_s)).to eq(['Title is required'])
      end
    end
  end

  context 'after parsing input containing newlines' do
    before { form.parse('title=This+is+a+product.%0AIt+is+very+lovely.') }

    describe '#valid?' do
      it 'returns false' do
        expect(form.valid?).to eq(false)
      end
    end
  end

  context 'with an errors translation' do
    before { I18n.backend.store_translations :en, {formeze: {errors: {required: 'cannot be blank'}}} }

    after { I18n.reload! }

    context 'after parsing blank input' do
      before { form.parse('title=') }

      describe '#errors' do
        it 'uses the errors translation' do
          expect(form.errors.first.to_s).to eq('Title cannot be blank')
        end
      end
    end
  end

  context 'with a labels translation' do
    before { I18n.backend.store_translations :en, {formeze: {labels: {title: 'TITLE'}}} }

    after { I18n.reload! }

    context 'after parsing blank input' do
      before { form.parse('title=') }

      describe '#errors' do
        it 'uses the labels translation' do
          expect(form.errors.first.to_s).to eq('TITLE is required')
        end
      end
    end
  end
end

RSpec.describe 'Form with fields' do
  class FormWithFields < Formeze::Form
    field :title
    field :steps
  end

  let(:form) { FormWithFields.new }

  context 'with a field specific errors translation' do
    before { I18n.backend.store_translations :en, {'FormWithFields' => {errors: {steps: {required: 'are required'}}}} }

    after { I18n.reload! }

    context 'after parsing blank input' do
      before { form.parse('title=&steps=') }

      describe '#errors' do
        it 'uses the translation' do
          expect(form.errors.map(&:to_s)).to include('Title is required')
          expect(form.errors.map(&:to_s)).to include('Steps are required')
        end
      end
    end
  end
end

RSpec.describe 'Form with optional field' do
  class FormWithOptionalField < Formeze::Form
    field :title, required: false
  end

  let(:form) { FormWithOptionalField.new }

  context 'after parsing blank input' do
    before { form.parse('title=') }

    describe '#title' do
      it 'returns nil' do
        expect(form.title).to be_nil
      end
    end

    describe '#valid?' do
      it 'returns true' do
        expect(form.valid?).to eq(true)
      end
    end
  end
end

RSpec.describe 'Form with optional field and blank option' do
  class FormWithOptionalFieldUsingBlankOption < Formeze::Form
    field :title, required: false, blank: 42
  end

  let(:form) { FormWithOptionalFieldUsingBlankOption.new }

  context 'after parsing blank input' do
    before { form.parse('title=') }

    describe '#title' do
      it 'returns the value specified by the blank option' do
        expect(form.title).to eq(42)
      end
    end
  end
end

RSpec.describe 'Form with multiline option' do
  class FormWithFieldThatCanHaveMultipleLines < Formeze::Form
    field :description, multiline: true
  end

  let(:form) { FormWithFieldThatCanHaveMultipleLines.new }

  context 'after parsing input containing newlines' do
    before { form.parse('description=This+is+a+product.%0AIt+is+very+lovely.') }

    describe '#valid?' do
      it 'returns true' do
        expect(form.valid?).to eq(true)
      end
    end
  end
end

RSpec.describe 'Form with maxlength option' do
  class FormWithMaxLengthField < Formeze::Form
    field :title, maxlength: 16
  end

  let(:form) { FormWithMaxLengthField.new }

  context 'after parsing input with too many characters' do
    before { form.parse('title=This+Title+Will+Be+Too+Long') }

    describe '#valid?' do
      it 'returns false' do
        expect(form.valid?).to eq(false)
      end
    end
  end
end

RSpec.describe 'Form with minlength option' do
  class FormWithMinLengthField < Formeze::Form
    field :title, minlength: 8
  end

  let(:form) { FormWithMinLengthField.new }

  context 'after parsing input with too few characters' do
    before { form.parse('title=Hello') }

    describe '#valid?' do
      it 'returns false' do
        expect(form.valid?).to eq(false)
      end
    end
  end
end

RSpec.describe 'Form with pattern option' do
  class FormWithFieldThatMustMatchPattern < Formeze::Form
    field :number, pattern: /\A\d+\z/
  end

  let(:form) { FormWithFieldThatMustMatchPattern.new }

  context 'after parsing input that matches the pattern' do
    before { form.parse('number=12345') }

    describe '#valid?' do
      it 'returns true' do
        expect(form.valid?).to eq(true)
      end
    end
  end

  context 'after parsing input that does not match the pattern' do
    before { form.parse('number=notanumber') }

    describe '#valid?' do
      it 'returns false' do
        expect(form.valid?).to eq(false)
      end
    end
  end
end

RSpec.describe 'Form with multiple option' do
  class FormWithFieldThatCanHaveMultipleValues < Formeze::Form
    field :colour, multiple: true
  end

  let(:form) { FormWithFieldThatCanHaveMultipleValues.new }

  describe '#colour' do
    it 'returns nil' do
      expect(form.colour).to be_nil
    end
  end

  describe '#colour=' do
    it 'adds the argument to the colour attribute array' do
      form.colour = 'black'

      expect(form.colour).to include('black')
    end
  end

  describe '#parse' do
    it 'adds the value to the colour attribute array' do
      form.parse('colour=black')

      expect(form.colour).to include('black')
    end

    it 'does not raise an exception when there are multiple values for the key' do
      form.parse('colour=black&colour=white')
    end

    it 'does not raise an exception when the key is missing' do
      form.parse('')
    end
  end

  context 'after parsing input with multiple values' do
    before { form.parse('colour=black&colour=white') }

    describe '#colour' do
      it 'returns an array containing the values' do
        expect(form.colour).to eq(['black', 'white'])
      end
    end

    describe '#valid?' do
      it 'returns true' do
        expect(form.valid?).to eq(true)
      end
    end

    describe '#to_hash' do
      it 'returns a hash containing the field name and its array value' do
        expect(form.to_hash).to eq({colour: %w[black white]})
      end
    end
  end

  context 'after parsing input with no values' do
    before { form.parse('') }

    describe '#colour' do
      it 'returns nil' do
        expect(form.colour).to be_nil
      end
    end

    describe '#valid?' do
      it 'returns true' do
        expect(form.valid?).to eq(true)
      end
    end
  end
end

RSpec.describe 'Form with values option' do
  class FormWithFieldThatCanOnlyHaveSpecifiedValues < Formeze::Form
    field :answer, values: %w[yes no]
  end

  let(:form) { FormWithFieldThatCanOnlyHaveSpecifiedValues.new }

  context 'after parsing input with an invalid value' do
    before { form.parse('answer=maybe') }

    describe '#valid?' do
      it 'returns false' do
        expect(form.valid?).to eq(false)
      end
    end
  end
end

RSpec.describe 'Form with defined_if lambda' do
  class FormWithGuardCondition < Formeze::Form
    field :account_name
    field :account_vat_number, defined_if: ->{ @business_account }

    def initialize(business_account)
      @business_account = business_account
    end
  end

  context 'with business_account set to false' do
    let(:form) { FormWithGuardCondition.new(false) }

    describe '#parse' do
      it 'raises an exception when the account_vat_number key is present' do
        expect { form.parse('account_name=Something&account_vat_number=123456789') }.to raise_error(Formeze::KeyError)
      end
    end

    context 'after parsing valid input' do
      before { form.parse('account_name=Something') }

      describe '#valid?' do
        it 'returns true' do
          expect(form.valid?).to eq(true)
        end
      end
    end
  end

  context 'with business_account set to true' do
    let(:form) { FormWithGuardCondition.new(true) }

    describe '#parse' do
      it 'raises an exception when the account_vat_number key is missing' do
        expect { form.parse('account_name=Something') }.to raise_error(Formeze::KeyError)
      end
    end
  end
end

RSpec.describe 'Form with defined_unless lambda' do
  class FormWithDefinedUnlessLambda < Formeze::Form
    field :delivery_address
    field :same_address, values: %w[yes no]
    field :billing_address, defined_unless: ->{ same_address == 'yes' }
  end

  let(:form) { FormWithDefinedUnlessLambda.new }

  describe '#parse' do
    it 'raises an exception when there is an unexpected key' do
      expect { form.parse('delivery_address=123+Main+St&same_address=yes&foo=bar') }.to raise_error(Formeze::KeyError)
    end
  end

  context 'after parsing input with same_address set and no billing address' do
    before { form.parse('delivery_address=123+Main+St&same_address=yes') }

    describe '#valid?' do
      it 'returns true' do
        expect(form.valid?).to eq(true)
      end
    end
  end
end

RSpec.describe 'Form with defined_unless proc' do
  class FormWithDefinedUnlessProc < Formeze::Form
    field :delivery_address
    field :same_address, values: %w[yes no]
    field :billing_address, defined_unless: proc { same_address == 'yes' }
  end

  let(:form) { FormWithDefinedUnlessProc.new }

  describe '#parse' do
    it 'raises an exception when there is an unexpected key' do
      expect { form.parse('delivery_address=123+Main+St&same_address=yes&foo=bar') }.to raise_error(Formeze::KeyError)
    end
  end

  context 'after parsing input with same_address set and no billing address' do
    before { form.parse('delivery_address=123+Main+St&same_address=yes') }

    describe '#valid?' do
      it 'returns true' do
        expect(form.valid?).to eq(true)
      end
    end
  end
end

RSpec.describe 'Form with defined_unless symbol' do
  class FormWithHaltingCondition < Formeze::Form
    field :delivery_address
    field :same_address, values: %w[yes no]
    field :billing_address, defined_unless: :same_address?

    def same_address?
      same_address == 'yes'
    end
  end

  let(:form) { FormWithHaltingCondition.new }

  describe '#parse' do
    it 'raises an exception when there is an unexpected key' do
      expect { form.parse('delivery_address=123+Main+St&same_address=yes&foo=bar') }.to raise_error(Formeze::KeyError)
    end
  end

  context 'after parsing input with same_address set and no billing address' do
    before { form.parse('delivery_address=123+Main+St&same_address=yes') }

    describe '#valid?' do
      it 'returns true' do
        expect(form.valid?).to eq(true)
      end
    end
  end
end

RSpec.describe 'Form with key_required option' do
  class FormWithOptionalKey < Formeze::Form
    field :accept_terms, values: %w[true], key_required: false
  end

  let(:form) { FormWithOptionalKey.new }

  context 'after parsing input without the key' do
    before { form.parse('') }

    describe '#valid?' do
      it 'returns true' do
        expect(form.valid?).to eq(true)
      end
    end
  end
end

RSpec.describe 'Form with optional field and values option' do
  class FormWithOptionalFieldThatCanOnlyHaveSpecifiedValues < Formeze::Form
    field :size, required: false, values: %w[S M L XL]
  end

  let(:form) { FormWithOptionalFieldThatCanOnlyHaveSpecifiedValues.new }

  context 'after parsing blank input' do
    before { form.parse('size=') }

    describe '#valid?' do
      it 'returns true' do
        expect(form.valid?).to eq(true)
      end
    end
  end
end

RSpec.describe 'Form with validation block' do
  class FormWithCustomEmailValidation < Formeze::Form
    field :email

    validates :email do |address|
      address.include?('@')
    end
  end

  let(:form) { FormWithCustomEmailValidation.new }

  context 'after parsing invalid input' do
    before { form.parse('email=alice') }

    describe '#valid?' do
      it 'returns false' do
        expect(form.valid?).to eq(false)
      end
    end

    describe '#errors' do
      it 'includes a generic error message for the named field' do
        expect(form.errors.map(&:to_s)).to include('Email is invalid')
      end
    end

    describe '#errors_on?' do
      it 'returns true when given the field name' do
        expect(form.errors_on?(:email)).to eq(true)
      end
    end
  end

  context 'after parsing blank input' do
    before { form.parse('email=') }

    describe '#errors' do
      it 'does not include the custom validation error message' do
        expect(form.errors.map(&:to_s)).not_to include('Email is invalid')
      end
    end
  end

  context 'with an errors translation' do
    before { I18n.backend.store_translations :en, {formeze: {errors: {invalid: 'is not valid'}}} }

    after { I18n.reload! }

    context 'after parsing invalid input' do
      before { form.parse('email=alice') }

      describe '#errors' do
        it 'uses the errors translation' do
          expect(form.errors.first.to_s).to eq('Email is not valid')
        end
      end
    end
  end
end

RSpec.describe 'Form with validation block and error option' do
  class FormWithCustomPasswordConfirmationCheck < Formeze::Form
    field :password
    field :password_confirmation

    validates :password_confirmation, error: :does_not_match do
      password_confirmation == password
    end
  end

  let(:form) { FormWithCustomPasswordConfirmationCheck.new }

  context 'after parsing invalid input' do
    before { form.parse('password=foo&password_confirmation=bar') }

    describe '#valid?' do
      it 'returns false' do
        expect(form.valid?).to eq(false)
      end
    end

    describe '#errors' do
      it 'includes a generic error message for the named field' do
        expect(form.errors.map(&:to_s)).to include('Password confirmation is invalid')
      end
    end

    describe '#errors_on?' do
      it 'returns true when given the field name' do
        expect(form.errors_on?(:password_confirmation)).to eq(true)
      end
    end
  end

  context 'with an errors translation' do
    before { I18n.backend.store_translations :en, {formeze: {errors: {does_not_match: 'does not match'}}} }

    after { I18n.reload! }

    context 'after parsing invalid input' do
      before { form.parse('password=foo&password_confirmation=bar') }

      describe '#errors' do
        it 'uses the errors translation' do
          expect(form.errors.first.to_s).to eq('Password confirmation does not match')
        end
      end
    end
  end
end

RSpec.describe 'Form with validation block and if option' do
  class FormWithCustomMinimumSpendValidation < Formeze::Form
    field :minimum_spend
    field :fixed_discount, required: false, blank: nil

    validates :minimum_spend, if: :fixed_discount? do
      minimum_spend.to_f > 0
    end

    def fixed_discount?
      !fixed_discount.nil?
    end
  end

  let(:form) { FormWithCustomMinimumSpendValidation.new }

  context 'after parsing valid input' do
    before { form.parse('minimum_spend=0.00&fixed_discount=') }

    describe '#valid?' do
      it 'returns true' do
        expect(form.valid?).to eq(true)
      end
    end

    describe '#errors' do
      it 'returns an empty array' do
        expect(form.errors).to be_empty
      end
    end

    describe '#errors_on?' do
      it 'returns false when given the field name' do
        expect(form.errors_on?(:minimum_spend)).to eq(false)
      end
    end
  end

  context 'after parsing invalid input' do
    before { form.parse('minimum_spend=0.00&fixed_discount=10%25') }

    describe '#valid?' do
      it 'returns false' do
        expect(form.valid?).to eq(false)
      end
    end

    describe '#errors' do
      it 'includes a generic error message for the named field' do
        expect(form.errors.map(&:to_s)).to include('Minimum spend is invalid')
      end
    end

    describe '#errors_on?' do
      it 'returns true when given the field name' do
        expect(form.errors_on?(:minimum_spend)).to eq(true)
      end
    end
  end
end

RSpec.describe 'Form with multiple field and validation block' do
  class FormWithMultipleOptionAndCustomValidation < Formeze::Form
    field :path, multiple: true

    validates :path do
      path.all? { _1.start_with?('/') }
    end
  end

  let(:form) { FormWithMultipleOptionAndCustomValidation.new }

  context 'after parsing invalid input' do
    before { form.parse('path=foo') }

    describe '#valid?' do
      it 'returns false' do
        expect(form.valid?).to eq(false)
      end
    end

    describe '#errors' do
      it 'includes an error message for the field' do
        expect(form.errors.map(&:to_s)).to include('Path is invalid')
      end
    end

    describe '#errors_on?' do
      it 'returns true when given the field name' do
        expect(form.errors_on?(:path)).to eq(true)
      end
    end
  end

  context 'after parsing valid input' do
    before { form.parse('path=%2Ffoo') }

    describe '#valid?' do
      it 'returns true' do
        expect(form.valid?).to eq(true)
      end
    end

    describe '#errors' do
      it 'returns an empty array' do
        expect(form.errors).to be_empty
      end
    end

    describe '#errors_on?' do
      it 'returns false when given the field name' do
        expect(form.errors_on?(:path)).to eq(false)
      end
    end
  end
end

RSpec.describe 'Form with optional field and validation block' do
  class FormWithOptionalFieldAndCustomValidation < Formeze::Form
    field :website, required: false

    validates :website do
      website =~ /\./ && website !~ /\s/
    end
  end

  let(:form) { FormWithOptionalFieldAndCustomValidation.new }

  context 'after parsing blank input' do
    before { form.parse('website=') }

    describe '#valid?' do
      it 'returns true' do
        expect(form.valid?).to eq(true)
      end
    end

    describe '#errors' do
      it 'returns an empty array' do
        expect(form.errors).to be_empty
      end
    end

    describe '#errors_on?' do
      it 'returns false when given the field name' do
        expect(form.errors_on?(:website)).to eq(false)
      end
    end
  end
end

RSpec.describe 'Form with maxsize option and accept option' do
  class FormWithFileField < Formeze::Form
    field :file, maxsize: 42, accept: 'text/plain'
  end

  let(:form) { FormWithFileField.new }

  context 'after parsing multipart input' do
    before do
      body = <<~EOS.gsub(/\n/, "\r\n")
        --AaB03x
        Content-Disposition: form-data; name="file"; filename="example.txt"
        Content-Type: text/plain

        contents
        --AaB03x--
      EOS

      form.parse(mock_request(body))
    end

    describe '#file' do
      it 'returns the value of the field' do
        expect(form.file).to be_instance_of(Rack::Multipart::UploadedFile)
        expect(form.file.original_filename).to eq('example.txt')
        expect(form.file.content_type).to eq('text/plain')
      end
    end

    describe '#valid?' do
      it 'returns true' do
        expect(form.valid?).to eq(true)
      end
    end

    describe '#errors?' do
      it 'returns false' do
        expect(form.errors?).to eq(false)
      end
    end

    describe '#errors' do
      it 'returns an empty array' do
        expect(form.errors).to eq([])
      end
    end

    describe '#errors_on?' do
      it 'returns false when given the file field name' do
        expect(form.errors_on?(:file)).to eq(false)
      end
    end

    describe '#errors_on' do
      it 'returns an empty array when given the file field name' do
        expect(form.errors_on(:file)).to eq([])
      end
    end
  end

  context 'after parsing blank multipart input' do
    before do
      body = <<~EOS.gsub(/\n/, "\r\n")
        --AaB03x
        Content-Disposition: form-data; name="file"; filename=""
        Content-Type: application/octet-stream


        --AaB03x--
      EOS

      form.parse(mock_request(body))
    end

    describe '#errors?' do
      it 'returns true' do
        expect(form.errors?).to eq(true)
      end
    end

    describe '#errors' do
      it 'returns an array containing a single error message' do
        expect(form.errors.map(&:to_s)).to eq(['File is required'])
      end
    end

    describe '#errors_on?' do
      it 'returns true when given the file field name' do
        expect(form.errors_on?(:file)).to eq(true)
      end
    end

    describe '#errors_on' do
      it 'returns an array containing a single error message when given the file field name' do
        expect(form.errors_on(:file).map(&:to_s)).to eq(['File is required'])
      end
    end
  end

  context 'after parsing multipart input with too much data' do
    before do
      body = <<~EOS.gsub(/\n/, "\r\n")
        --AaB03x
        Content-Disposition: form-data; name="file"; filename="example.txt"
        Content-Type: text/plain

        The quick brown fox jumps over the lazy dog.
        --AaB03x--
      EOS

      form.parse(mock_request(body))
    end

    describe '#errors?' do
      it 'returns true' do
        expect(form.errors?).to eq(true)
      end
    end

    describe '#errors' do
      it 'returns an array containing a single error message' do
        expect(form.errors.map(&:to_s)).to eq(['File is too large'])
      end
    end

    describe '#errors_on?' do
      it 'returns true when given the file field name' do
        expect(form.errors_on?(:file)).to eq(true)
      end
    end

    describe '#errors_on' do
      it 'returns an array containing a single error message when given the file field name' do
        expect(form.errors_on(:file).map(&:to_s)).to eq(['File is too large'])
      end
    end
  end

  context 'after parsing multipart input with an unacceptable content type' do
    before do
      body = <<~EOS.gsub(/\n/, "\r\n")
        --AaB03x
        Content-Disposition: form-data; name="file"; filename="example.html"
        Content-Type: text/html

        <!DOCTYPE html> 
        --AaB03x--
      EOS

      form.parse(mock_request(body))
    end

    describe '#errors?' do
      it 'returns true' do
        expect(form.errors?).to eq(true)
      end
    end

    describe '#errors' do
      it 'returns an array containing a single error message' do
        expect(form.errors.map(&:to_s)).to eq(['File is not an accepted file type'])
      end
    end

    describe '#errors_on?' do
      it 'returns true when given the file field name' do
        expect(form.errors_on?(:file)).to eq(true)
      end
    end

    describe '#errors_on' do
      it 'returns an array containing a single error message when given the file field name' do
        expect(form.errors_on(:file).map(&:to_s)).to eq(['File is not an accepted file type'])
      end
    end
  end
end

RSpec.describe 'Form with accept option and multiple option' do
  class FormWithMultipleFileField < Formeze::Form
    field :file, accept: 'text/plain', multiple: true
  end

  let(:form) { FormWithMultipleFileField.new }

  context 'after parsing multipart input with no files' do
    before do
      body = <<~EOS.gsub(/\n/, "\r\n")
        --AaB03x
        Content-Disposition: form-data; name="file"; filename=""
        Content-Type: application/octet-stream


        --AaB03x
        Content-Disposition: form-data; name="file"; filename=""
        Content-Type: application/octet-stream


        --AaB03x--
      EOS

      form.parse(mock_request(body))
    end

    describe '#file' do
      it 'returns nil' do
        expect(form.file).to be_nil
      end
    end

    describe '#valid?' do
      it 'returns true' do
        expect(form.valid?).to eq(true)
      end
    end

    describe '#errors?' do
      it 'returns false' do
        expect(form.errors?).to eq(false)
      end
    end

    describe '#errors' do
      it 'returns an empty array' do
        expect(form.errors).to eq([])
      end
    end
  end

  context 'after parsing multipart input with one file' do
    before do
      body = <<~EOS.gsub(/\n/, "\r\n")
        --AaB03x
        Content-Disposition: form-data; name="file"; filename="file1.txt"
        Content-Type: text/plain

        1
        --AaB03x
        Content-Disposition: form-data; name="file"; filename=""
        Content-Type: application/octet-stream


        --AaB03x--
      EOS

      form.parse(mock_request(body))
    end

    describe '#file' do
      it 'returns an array' do
        expect(form.file).to be_an(Array)
        expect(form.file.length).to eq(1)
        expect(form.file[0]).to be_a(Rack::Multipart::UploadedFile)
        expect(form.file[0].original_filename).to eq('file1.txt')
        expect(form.file[0].content_type).to eq('text/plain')
      end
    end

    describe '#valid?' do
      it 'returns true' do
        expect(form.valid?).to eq(true)
      end
    end

    describe '#errors?' do
      it 'returns false' do
        expect(form.errors?).to eq(false)
      end
    end

    describe '#errors' do
      it 'returns an empty array' do
        expect(form.errors).to eq([])
      end
    end
  end

  context 'after parsing multipart input with multiple files' do
    before do
      body = <<~EOS.gsub(/\n/, "\r\n")
        --AaB03x
        Content-Disposition: form-data; name="file"; filename="file1.txt"
        Content-Type: text/plain

        1
        --AaB03x
        Content-Disposition: form-data; name="file"; filename="file2.txt"
        Content-Type: text/plain

        2
        --AaB03x--
      EOS

      form.parse(mock_request(body))
    end

    describe '#file' do
      it 'returns an array' do
        expect(form.file).to be_an(Array)
        expect(form.file.length).to eq(2)
        expect(form.file[0]).to be_a(Rack::Multipart::UploadedFile)
        expect(form.file[0].original_filename).to eq('file1.txt')
        expect(form.file[0].content_type).to eq('text/plain')
        expect(form.file[1]).to be_a(Rack::Multipart::UploadedFile)
        expect(form.file[1].original_filename).to eq('file2.txt')
        expect(form.file[1].content_type).to eq('text/plain')
      end
    end

    describe '#valid?' do
      it 'returns true' do
        expect(form.valid?).to eq(true)
      end
    end

    describe '#errors?' do
      it 'returns false' do
        expect(form.errors?).to eq(false)
      end
    end

    describe '#errors' do
      it 'returns an empty array' do
        expect(form.errors).to eq([])
      end
    end
  end
end

RSpec.describe 'Form with fill option' do
  class FormWithFillOption < Formeze::Form
    field :title, fill: ->(string) { string.upcase }
  end

  let(:form) { FormWithFillOption.new }

  describe '#fill' do
    it 'uses the proc specified by the fill option' do
      form.fill('title')

      expect(form.title).to eq('TITLE')
    end
  end
end

RSpec.describe 'Form with scrub option' do
  class FormWithScrubbedFields < Formeze::Form
    field :postcode, scrub: [:strip, :squeeze, :upcase], pattern: /\A[A-Z0-9]{2,4} [A-Z0-9]{3}\z/
    field :bio, scrub: [:strip, :squeeze_lines], multiline: true
  end

  let(:form) { FormWithScrubbedFields.new }

  describe '#parse' do
    it 'applies the scrub methods to the input before validation' do
      form.parse('postcode=++sw1a+++1aa&bio=My+name+is+Cookie+Monster.%0A%0A%0A%0AI+LOVE+COOKIES!!!!%0A%0A%0A%0A')

      expect(form.postcode).to eq('SW1A 1AA')
      expect(form.bio.count("\n")).to eq(2)
      expect(form.valid?).to eq(true)
    end
  end
end

RSpec.describe 'Form with call to Formeze.setup' do
  class FormClassWithExplicitSetupCall
    Formeze.setup(self)
  end

  let(:form_class) { FormClassWithExplicitSetupCall }

  it 'includes the formeze class methods and instance methods' do
    expect(form_class.singleton_class).to include(Formeze::ClassMethods)

    expect(form_class).to include(Formeze::InstanceMethods)
  end
end

RSpec.describe 'Formeze' do
  describe '.scrub' do
    it 'applies the scrub methods to the given input' do
      expect(Formeze.scrub("word\n\n", [:strip, :upcase])).to eq('WORD')
    end
  end
end
