require_relative '../../lib/formeze'

RSpec.describe Formeze::Presence do
  include described_class

  describe '#present?' do
    context 'with nil' do
      it 'returns false' do
        expect(present?(nil)).to eq(false)
      end
    end

    context 'with an empty array' do
      it 'returns false' do
        expect(present?([])).to eq(false)
      end
    end

    context 'with an empty string' do
      it 'returns false' do
        expect(present?('')).to eq(false)
      end
    end

    context 'with a string that only contains whitespace characters' do
      it 'returns false' do
        expect(present?(" \t\r\n")).to eq(false)
      end
    end

    context 'with a string that contains non-whitespace characters' do
      it 'returns true' do
        expect(present?('123')).to eq(true)
      end
    end
  end
end
