require 'minitest/autorun'

require 'formeze'

class FormWithField
  Formeze.setup(self)

  field :title
end

describe 'FormWithField' do
  before do
    @form = FormWithField.new
  end

  describe 'title method' do
    it 'should return nil' do
      @form.title.must_be_nil
    end
  end

  describe 'title equals method' do
    it 'should set the value of the title attribute' do
      @form.title = 'Untitled'
      @form.title.must_equal('Untitled')
    end
  end

  describe 'parse method' do
    it 'should set the value of the title attribute' do
      @form.parse('title=Untitled')
      @form.title.must_equal('Untitled')
    end

    it 'should raise an exception when the key is missing' do
      proc { @form.parse('') }.must_raise(Formeze::KeyError)
    end

    it 'should raise an exception when there are multiple values for the key' do
      proc { @form.parse('title=foo&title=bar') }.must_raise(Formeze::ValueError)
    end

    it 'should raise an exception when there is an unexpected key' do
      proc { @form.parse('title=Untitled&foo=bar') }.must_raise(Formeze::KeyError)
    end
  end
end

describe 'FormWithField after parsing valid input' do
  before do
    @form = FormWithField.new
    @form.parse('title=Untitled')
  end

  describe 'valid query method' do
    it 'should return true' do
      @form.valid?.must_equal(true)
    end
  end

  describe 'errors method' do
    it 'should return an empty array' do
      @form.errors.must_be_instance_of(Array)
      @form.errors.must_be_empty
    end
  end
end

describe 'FormWithField after parsing blank input' do
  before do
    @form = FormWithField.new
    @form.parse('title=')
  end

  describe 'valid query method' do
    it 'should return false' do
      @form.valid?.must_equal(false)
    end
  end
end

describe 'FormWithField after parsing input containing newlines' do
  before do
    @form = FormWithField.new
    @form.parse('title=This+is+a+product.%0AIt+is+very+lovely.')
  end

  describe 'valid query method' do
    it 'should return false' do
      @form.valid?.must_equal(false)
    end
  end
end

class FormWithOptionalField
  Formeze.setup(self)

  field :title, required: false
end

describe 'FormWithOptionalField after parsing blank input' do
  before do
    @form = FormWithOptionalField.new
    @form.parse('title=')
  end

  describe 'valid query method' do
    it 'should return true' do
      @form.valid?.must_equal(true)
    end
  end
end

class FormWithFieldThatCanHaveMultipleLines
  Formeze.setup(self)

  field :description, multiline: true
end

describe 'FormWithFieldThatCanHaveMultipleLines after parsing input containing newlines' do
  before do
    @form = FormWithFieldThatCanHaveMultipleLines.new
    @form.parse('description=This+is+a+product.%0AIt+is+very+lovely.')
  end

  describe 'valid query method' do
    it 'should return true' do
      @form.valid?.must_equal(true)
    end
  end
end

class FormWithCharacterLimitedField
  Formeze.setup(self)

  field :title, char_limit: 16
end

describe 'FormWithCharacterLimitedField after parsing input with too many characters' do
  before do
    @form = FormWithCharacterLimitedField.new
    @form.parse('title=This+Title+Will+Be+Too+Long')
  end

  describe 'valid query method' do
    it 'should return false' do
      @form.valid?.must_equal(false)
    end
  end
end

class FormWithWordLimitedField
  Formeze.setup(self)

  field :title, word_limit: 2
end

describe 'FormWithWordLimitedField after parsing input with too many words' do
  before do
    @form = FormWithWordLimitedField.new
    @form.parse('title=This+Title+Will+Be+Too+Long')
  end

  describe 'valid query method' do
    it 'should return false' do
      @form.valid?.must_equal(false)
    end
  end
end

class FormWithFieldThatMustMatchPattern
  Formeze.setup(self)

  field :number, pattern: /\A\d+\z/
end

describe 'FormWithFieldThatMustMatchPattern after parsing input that matches the pattern' do
  before do
    @form = FormWithFieldThatMustMatchPattern.new
    @form.parse('number=12345')
  end

  describe 'valid query method' do
    it 'should return true' do
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
    it 'should return false' do
      @form.valid?.must_equal(false)
    end
  end
end

class FormWithFieldThatCanHaveMultipleValues
  Formeze.setup(self)

  field :colour, multiple: true
end

describe 'FormWithFieldThatCanHaveMultipleValues' do
  before do
    @form = FormWithFieldThatCanHaveMultipleValues.new
  end

  describe 'colour method' do
    it 'should return an empty array' do
      @form.colour.must_be_instance_of(Array)
      @form.colour.must_be_empty
    end
  end

  describe 'colour equals method' do
    it 'should add the argument to the colour attribute array' do
      @form.colour = 'black'
      @form.colour.must_include('black')
    end
  end

  describe 'parse method' do
    it 'should add the value to the colour attribute array' do
      @form.parse('colour=black')
      @form.colour.must_include('black')
    end

    it 'should not raise an exception when there are multiple values for the key' do
      @form.parse('colour=black&colour=white')
    end

    it 'should not raise an exception when the key is missing' do
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
    it 'should return an array containing the values' do
      @form.colour.must_be_instance_of(Array)
      @form.colour.must_include('black')
      @form.colour.must_include('white')
    end
  end

  describe 'valid query method' do
    it 'should return true' do
      @form.valid?.must_equal(true)
    end
  end
end

describe 'FormWithFieldThatCanHaveMultipleValues after parsing input with no values' do
  before do
    @form = FormWithFieldThatCanHaveMultipleValues.new
    @form.parse('')
  end

  describe 'colour method' do
    it 'should return an empty array' do
      @form.colour.must_be_instance_of(Array)
      @form.colour.must_be_empty
    end
  end

  describe 'valid query method' do
    it 'should return true' do
      @form.valid?.must_equal(true)
    end
  end
end

class FormWithFieldThatCanOnlyHaveSpecifiedValues
  Formeze.setup(self)

  field :answer, values: %w(yes no)
end

describe 'FormWithFieldThatCanOnlyHaveSpecifiedValues after parsing input with an invalid value' do
  before do
    @form = FormWithFieldThatCanOnlyHaveSpecifiedValues.new
    @form.parse('answer=maybe')
  end

  describe 'valid query method' do
    it 'should return false' do
      @form.valid?.must_equal(false)
    end
  end
end
