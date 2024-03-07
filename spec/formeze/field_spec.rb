require_relative '../../lib/formeze'
require 'mime-types'

RSpec.describe Formeze::Field do
  describe '#acceptable_file?' do
    let(:subject) { described_class.new(:file, accept: 'text/plain,text/rtf') }

    context 'when content type is invalid' do
      let(:upload) { double('Upload', content_type: 'text/invalid', original_filename: 'file.txt') }

      it 'returns false' do
        expect(subject.acceptable_file?(upload)).to eq(false)
      end
    end

    context 'when content type is included in the filename types' do
      let(:upload) { double('Upload', content_type: 'text/rtf', original_filename: 'file.rtf') }

      context 'when accept includes the type' do
        it 'returns true' do
          expect(subject.acceptable_file?(upload)).to eq(true)
        end
      end

      context 'when accept does not include the type' do
        let(:subject) { described_class.new(:file, accept: 'image/png') }

        it 'returns false' do
          expect(subject.acceptable_file?(upload)).to eq(false)
        end
      end
    end

    context 'when content type is not included in the filename types' do
      let(:upload) { double('Upload', content_type: 'text/html', original_filename: 'file.txt') }

      it 'returns false' do
        expect(subject.acceptable_file?(upload)).to eq(false)
      end
    end

    context 'when content type is application/octet-stream' do
      let(:upload) { double('Upload', content_type: 'application/octet-stream', original_filename: 'file.md') }

      context 'when accept includes the first filename type' do
        let(:subject) { described_class.new(:file, accept: 'text/markdown') }

        it 'returns true' do
          expect(subject.acceptable_file?(upload)).to eq(true)
        end
      end

      context 'when accept does not include the first filename type' do
        let(:subject) { described_class.new(:file, accept: 'text/plain') }

        it 'returns true' do
          expect(subject.acceptable_file?(upload)).to eq(false)
        end
      end
    end
  end
end
