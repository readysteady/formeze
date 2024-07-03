require 'spec_helper'

RSpec.describe Formeze::FormData do
  describe '.parse' do
    let(:body) { 'a=1&b=2&b=3' }
    let(:hash) { {'a' => ['1'], 'b' => ['2', '3']} }

    context 'with a string' do
      it 'returns a hash' do
        result = described_class.parse(body)

        expect(result).to eq(hash)
      end
    end

    context 'with a www form urlencoded request' do
      it 'returns a hash' do
        request = mock_request(body, content_type: 'application/x-www-form-urlencoded')

        result = described_class.parse(request)

        expect(result).to eq(hash)
      end
    end

    context 'with a multipart form data request' do
      it 'returns a hash' do
        body = <<~EOS.gsub(/\n/, "\r\n")
          --AaB03x
          content-disposition: form-data; name="a"

          1
          --AaB03x
          content-disposition: form-data; name="b"; filename="file1.txt"
          content-type: text/plain

          2
          --AaB03x
          content-disposition: form-data; name="b"; filename="file2.txt"
          content-type: text/plain

          3
          --AaB03x--
        EOS

        request = mock_request(body)

        result = described_class.parse(request)

        expect(result).to be_a(Hash)
        expect(result['a']).to eq(['1'])
        expect(result['b']).to be_an(Array)
        expect(result['b'].size).to eq(2)
        expect(result['b'][0]).to be_a(Rack::Multipart::UploadedFile)
        expect(result['b'][0].original_filename).to eq('file1.txt')
        expect(result['b'][0].content_type).to eq('text/plain')
        expect(result['b'][1]).to be_a(Rack::Multipart::UploadedFile)
        expect(result['b'][1].original_filename).to eq('file2.txt')
        expect(result['b'][1].content_type).to eq('text/plain')
      end
    end

    context 'with a multipart form data request that has blank data' do
      it 'includes the key with an empty array value' do
        body = <<~EOS.gsub(/\n/, "\r\n")
          --AaB03x
          Content-Disposition: form-data; name="a"; filename=""
          Content-Type: application/octet-stream


          --AaB03x--
        EOS

        request = mock_request(body)

        result = described_class.parse(request)

        expect(result).to be_a(Hash)
        expect(result['a']).to eq([])
      end
    end

    context 'with a multipart form data request that has missing data' do
      it 'includes the key with an empty array value' do
        body = <<~EOS.gsub(/\n/, "\r\n")
          --AaB03x
          content-disposition: form-data; name="x"

          1
          --AaB03x--
        EOS

        request = mock_request(body)

        result = described_class.parse(request)

        expect(result).to be_a(Hash)
        expect(result['a']).to eq([])
      end
    end
  end
end
