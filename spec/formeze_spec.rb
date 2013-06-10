require 'minitest/autorun'
require 'formeze'
require 'i18n'

class FormWithField < Formeze::Form
  field :title
end

describe 'FormWithField' do
  before do
    @form = FormWithField.new
  end

  describe 'title method' do
    it 'returns nil' do
      @form.title.must_be_nil
    end
  end

  describe 'title equals method' do
    it 'sets the value of the title attribute' do
      @form.title = 'Untitled'
      @form.title.must_equal('Untitled')
    end
  end

  describe 'parse method' do
    it 'sets the value of the title attribute' do
      @form.parse('title=Untitled')
      @form.title.must_equal('Untitled')
    end

    it 'raises an exception when the key is missing' do
      proc { @form.parse('') }.must_raise(Formeze::KeyError)
    end

    it 'raises an exception when there are multiple values for the key' do
      proc { @form.parse('title=foo&title=bar') }.must_raise(Formeze::ValueError)
    end

    it 'raises an exception when the data contains unexpected keys' do
      exception = proc { @form.parse('title=Untitled&foo=bar&baz=') }.must_raise(Formeze::KeyError)

      exception.message.must_equal('unexpected form keys: baz, foo')
    end
  end

  describe 'fill method' do
    it 'sets the value of the title attribute when given a hash with symbol keys' do
      @form.fill({:title => 'Untitled'})
      @form.title.must_equal('Untitled')
    end

    it 'sets the value of the title attribute when given an object with a title attribute' do
      object = Object.new

      def object.title; 'Untitled' end

      @form.fill(object)
      @form.title.must_equal('Untitled')
    end
  end
end

describe 'FormWithField after parsing valid input' do
  before do
    @form = FormWithField.new
    @form.parse('title=Untitled')
  end

  describe 'title method' do
    it 'returns the value of the field' do
      @form.title.must_equal('Untitled')
    end
  end

  describe 'valid query method' do
    it 'returns true' do
      @form.valid?.must_equal(true)
    end
  end

  describe 'errors query method' do
    it 'returns false' do
      @form.errors?.must_equal(false)
    end
  end

  describe 'errors method' do
    it 'returns an empty array' do
      @form.errors.must_be_instance_of(Array)
      @form.errors.must_be_empty
    end
  end

  describe 'errors_on query method' do
    it 'returns false when given the title field name' do
      @form.errors_on?(:title).must_equal(false)
    end
  end

  describe 'errors_on method' do
    it 'returns an empty array when given the title field name' do
      errors = @form.errors_on(:title)
      errors.must_be_instance_of(Array)
      errors.must_be_empty
    end
  end

  describe 'to_h method' do
    it 'returns a hash containing the field name and its value' do
      @form.to_h.must_equal({:title => 'Untitled'})
    end
  end

  describe 'to_hash method' do
    it 'returns a hash containing the field name and its value' do
      @form.to_hash.must_equal({:title => 'Untitled'})
    end
  end
end

describe 'FormWithField after parsing blank input' do
  before do
    @form = FormWithField.new
    @form.parse('title=')
  end

  describe 'valid query method' do
    it 'returns false' do
      @form.valid?.must_equal(false)
    end
  end

  describe 'errors query method' do
    it 'returns true' do
      @form.errors?.must_equal(true)
    end
  end

  describe 'errors method' do
    it 'returns an array containing a single error message' do
      @form.errors.must_be_instance_of(Array)
      @form.errors.length.must_equal(1)
      @form.errors.first.to_s.must_equal('Title is required')
    end
  end

  describe 'errors_on query method' do
    it 'returns true when given the title field name' do
      @form.errors_on?(:title).must_equal(true)
    end
  end

  describe 'errors_on method' do
    it 'returns an array containing a single error message when given the title field name' do
      errors = @form.errors_on(:title)
      errors.must_be_instance_of(Array)
      errors.length.must_equal(1)
      errors.first.to_s.must_equal('Title is required')
    end
  end
end

describe 'FormWithField after parsing input containing newlines' do
  before do
    @form = FormWithField.new
    @form.parse('title=This+is+a+product.%0AIt+is+very+lovely.')
  end

  describe 'valid query method' do
    it 'returns false' do
      @form.valid?.must_equal(false)
    end
  end
end

describe 'FormWithField parse class method' do
  it 'creates a new instance of the class and calls the parse instance method' do
    form = FormWithField.parse('title=Untitled')
    form.must_be_instance_of(FormWithField)
    form.valid?.must_equal(true)
    form.title.must_equal('Untitled')
  end
end

class FormWithOptionalField < Formeze::Form
  field :title, :required => false
end

describe 'FormWithOptionalField after parsing blank input' do
  before do
    @form = FormWithOptionalField.new
    @form.parse('title=')
  end

  describe 'valid query method' do
    it 'returns true' do
      @form.valid?.must_equal(true)
    end
  end
end

class FormWithOptionalFieldUsingBlankOption < Formeze::Form
  field :title, :required => false, :blank => 42
end

describe 'FormWithOptionalFieldUsingBlankOption after parsing blank input' do
  before do
    @form = FormWithOptionalFieldUsingBlankOption.new
    @form.parse('title=')
  end

  describe 'title method' do
    it 'returns the value specified by the blank option' do
      @form.title.must_equal(42)
    end
  end
end

class FormWithFieldThatCanHaveMultipleLines < Formeze::Form
  field :description, :multiline => true
end

describe 'FormWithFieldThatCanHaveMultipleLines after parsing input containing newlines' do
  before do
    @form = FormWithFieldThatCanHaveMultipleLines.new
    @form.parse('description=This+is+a+product.%0AIt+is+very+lovely.')
  end

  describe 'valid query method' do
    it 'returns true' do
      @form.valid?.must_equal(true)
    end
  end
end

class FormWithMaxLengthField < Formeze::Form
  field :title, :maxlength => 16
end

describe 'FormWithMaxLengthField after parsing input with too many characters' do
  before do
    @form = FormWithMaxLengthField.new
    @form.parse('title=This+Title+Will+Be+Too+Long')
  end

  describe 'valid query method' do
    it 'returns false' do
      @form.valid?.must_equal(false)
    end
  end
end

class FormWithMinLengthField < Formeze::Form
  field :title, :minlength => 8
end

describe 'FormWithMinLengthField after parsing input with too few characters' do
  before do
    @form = FormWithMinLengthField.new
    @form.parse('title=Hello')
  end

  describe 'valid query method' do
    it 'returns false' do
      @form.valid?.must_equal(false)
    end
  end
end

class FormWithWordLimitedField < Formeze::Form
  field :title, :word_limit => 2
end

describe 'FormWithWordLimitedField after parsing input with too many words' do
  before do
    @form = FormWithWordLimitedField.new
    @form.parse('title=This+Title+Will+Be+Too+Long')
  end

  describe 'valid query method' do
    it 'returns false' do
      @form.valid?.must_equal(false)
    end
  end
end

class FormWithFieldThatMustMatchPattern < Formeze::Form
  field :number, :pattern => /\A\d+\z/
end

describe 'FormWithFieldThatMustMatchPattern after parsing input that matches the pattern' do
  before do
    @form = FormWithFieldThatMustMatchPattern.new
    @form.parse('number=12345')
  end

  describe 'valid query method' do
    it 'returns true' do
      @form.valid?.must_equal(true)
    end
  end
end

describe 'FormWithFieldThatMustMatchPattern after parsing input that does not match the pattern' do
  before do
    @form = FormWithFieldThatMustMatchPattern.new
    @form.parse('number=notanumber')
  end

  describe 'valid query method' do
    it 'returns false' do
      @form.valid?.must_equal(false)
    end
  end
end

class FormWithFieldThatCanHaveMultipleValues < Formeze::Form
  field :colour, :multiple => true
end

describe 'FormWithFieldThatCanHaveMultipleValues' do
  before do
    @form = FormWithFieldThatCanHaveMultipleValues.new
  end

  describe 'colour method' do
    it 'returns an empty array' do
      @form.colour.must_be_instance_of(Array)
      @form.colour.must_be_empty
    end
  end

  describe 'colour equals method' do
    it 'adds the argument to the colour attribute array' do
      @form.colour = 'black'
      @form.colour.must_include('black')
    end
  end

  describe 'parse method' do
    it 'adds the value to the colour attribute array' do
      @form.parse('colour=black')
      @form.colour.must_include('black')
    end

    it 'does not raise an exception when there are multiple values for the key' do
      @form.parse('colour=black&colour=white')
    end

    it 'does not raise an exception when the key is missing' do
      @form.parse('')
    end
  end
end

describe 'FormWithFieldThatCanHaveMultipleValues after parsing input with multiple values' do
  before do
    @form = FormWithFieldThatCanHaveMultipleValues.new
    @form.parse('colour=black&colour=white')
  end

  describe 'colour method' do
    it 'returns an array containing the values' do
      @form.colour.must_be_instance_of(Array)
      @form.colour.must_include('black')
      @form.colour.must_include('white')
    end
  end

  describe 'valid query method' do
    it 'returns true' do
      @form.valid?.must_equal(true)
    end
  end

  describe 'to_hash method' do
    it 'returns a hash containing the field name and its array value' do
      @form.to_hash.must_equal({:colour => %w(black white)})
    end
  end
end

describe 'FormWithFieldThatCanHaveMultipleValues after parsing input with no values' do
  before do
    @form = FormWithFieldThatCanHaveMultipleValues.new
    @form.parse('')
  end

  describe 'colour method' do
    it 'returns an empty array' do
      @form.colour.must_be_instance_of(Array)
      @form.colour.must_be_empty
    end
  end

  describe 'valid query method' do
    it 'returns true' do
      @form.valid?.must_equal(true)
    end
  end
end

class FormWithFieldThatCanOnlyHaveSpecifiedValues < Formeze::Form
  field :answer, :values => %w(yes no)
end

describe 'FormWithFieldThatCanOnlyHaveSpecifiedValues after parsing input with an invalid value' do
  before do
    @form = FormWithFieldThatCanOnlyHaveSpecifiedValues.new
    @form.parse('answer=maybe')
  end

  describe 'valid query method' do
    it 'returns false' do
      @form.valid?.must_equal(false)
    end
  end
end

class FormWithGuardCondition < Formeze::Form
  field :account_name
  field :account_vat_number, :defined_if => proc { @business_account }

  def initialize(business_account)
    @business_account = business_account
  end
end

describe 'FormWithGuardCondition with business_account set to false' do
  before do
    @form = FormWithGuardCondition.new(false)
  end

  describe 'parse method' do
    it 'raises an exception when the account_vat_number key is present' do
      proc { @form.parse('account_name=Something&account_vat_number=123456789') }.must_raise(Formeze::KeyError)
    end
  end
end

describe 'FormWithGuardCondition with business_account set to true' do
  before do
    @form = FormWithGuardCondition.new(true)
  end

  describe 'parse method' do
    it 'raises an exception when the account_vat_number key is missing' do
      proc { @form.parse('account_name=Something') }.must_raise(Formeze::KeyError)
    end
  end
end

describe 'FormWithGuardCondition with business_account set to false after parsing valid input' do
  before do
    @form = FormWithGuardCondition.new(false)
    @form.parse('account_name=Something')
  end

  describe 'valid query method' do
    it 'returns true' do
      @form.valid?.must_equal(true)
    end
  end
end

class FormWithHaltingCondition < Formeze::Form
  field :delivery_address
  field :same_address, :values => %w(yes no)
  field :billing_address, :defined_unless => :same_address?

  def same_address?
    same_address == 'yes'
  end
end

describe 'FormWithHaltingCondition' do
  before do
    @form = FormWithHaltingCondition.new
  end

  describe 'parse method' do
    it 'raises an exception when there is an unexpected key' do
      proc { @form.parse('delivery_address=123+Main+St&same_address=yes&foo=bar') }.must_raise(Formeze::KeyError)
    end
  end
end

describe 'FormWithHaltingCondition after parsing input with same_address set and no billing address' do
  before do
    @form = FormWithHaltingCondition.new
    @form.parse('delivery_address=123+Main+St&same_address=yes')
  end

  describe 'valid query method' do
    it 'returns true' do
      @form.valid?.must_equal(true)
    end
  end
end

class FormWithCustomValidation < Formeze::Form
  field :email

  check { email.include?(?@) }
  error 'Email is invalid'
end

describe 'FormWithCustomValidation after parsing invalid input' do
  before do
    @form = FormWithCustomValidation.new
    @form.parse('email=alice')
  end

  describe 'valid query method' do
    it 'returns false' do
      @form.valid?.must_equal(false)
    end
  end
end

class FormWithOptionalKey < Formeze::Form
  field :accept_terms, :values => %w(true), :key_required => false
end

describe 'FormWithOptionalKey after parsing input without the key' do
  before do
    @form = FormWithOptionalKey.new
    @form.parse('')
  end

  describe 'valid query method' do
    it 'returns true' do
      @form.valid?.must_equal(true)
    end
  end
end

class FormWithOptionalFieldThatCanOnlyHaveSpecifiedValues < Formeze::Form
  field :size, :required => false, :values => %w(S M L XL)
end

describe 'FormWithOptionalFieldThatCanOnlyHaveSpecifiedValues after parsing blank input' do
  before do
    @form = FormWithOptionalFieldThatCanOnlyHaveSpecifiedValues.new
    @form.parse('size=')
  end

  describe 'valid query method' do
    it 'returns true' do
      @form.valid?.must_equal(true)
    end
  end
end

describe 'FormWithField on Rails' do
  before do
    @form = FormWithField.new

    Object.const_set(:Rails, Object.new)
  end

  after do
    Object.send(:remove_const, :Rails)
  end

  describe 'parse method' do
    it 'silently ignores the utf8 and authenticity_token parameters' do
      @form.parse('utf8=%E2%9C%93&authenticity_token=5RMc3sPZdR%2BZz4onNS8NfK&title=Test')
      @form.wont_respond_to(:utf8)
      @form.wont_respond_to(:authenticity_token)
      @form.to_hash.must_equal({:title => 'Test'})
    end
  end
end

describe 'I18n integration' do
  before do
    I18n.backend = I18n::Backend::Simple.new
  end

  after do
    I18n.backend = I18n::Backend::Simple.new
  end

  it 'provides i18n support for overriding the default error messages' do
    I18n.backend.store_translations :en, {:formeze => {:errors => {:required => 'cannot be blank'}}}

    form = FormWithField.new
    form.parse('title=')
    form.errors.first.to_s.must_equal('Title cannot be blank')
  end

  it 'provides i18n support for specifying field labels globally' do
    I18n.backend.store_translations :en, {:formeze => {:labels => {:title => 'TITLE'}}}

    form = FormWithField.new
    form.parse('title=')
    form.errors.first.to_s.must_equal('TITLE is required')
  end
end

class FormWithScrubbedFields < Formeze::Form
  field :postcode, :scrub => [:strip, :squeeze, :upcase], :pattern => /\A[A-Z0-9]{2,4} [A-Z0-9]{3}\z/
  field :bio, :scrub => [:strip, :squeeze_lines], :multiline => true
end

describe 'FormWithScrubbedFields' do
  describe 'parse method' do
    it 'applies the scrub methods to the input before validation' do
      form = FormWithScrubbedFields.new
      form.parse('postcode=++sw1a+++1aa&bio=My+name+is+Cookie+Monster.%0A%0A%0A%0AI+LOVE+COOKIES!!!!%0A%0A%0A%0A')
      form.postcode.must_equal('SW1A 1AA')
      form.bio.count("\n").must_equal(2)
      form.valid?.must_equal(true)
    end
  end
end

describe 'Formeze' do
  describe 'scrub module method' do
    it 'applies the scrub methods to the given input' do
      Formeze.scrub("word\n\n", [:strip, :upcase]).must_equal('WORD')
    end
  end
end

class FormClassWithExplicitSetupCall
  Formeze.setup(self)
end

describe 'FormClassWithExplicitSetupCall' do
  before do
    @form_class = FormClassWithExplicitSetupCall
  end

  it 'includes the formeze class methods and instance methods' do
    singleton_class = if @form_class.respond_to?(:singleton_class)
      @form_class.singleton_class
    else
      (class << @form_class; self; end)
    end

    singleton_class.must_include(Formeze::ClassMethods)

    @form_class.must_include(Formeze::InstanceMethods)
  end
end
