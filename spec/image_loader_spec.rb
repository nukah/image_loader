require 'spec_helper'

describe ImageLoader do
  subject { described_class.new(url).save }

  let(:url) { 'https://mili.ru' }
  let(:page_with_images) do
    Typhoeus::Response.new(code: 200, body: File.open(File.join('spec', 'support', 'page_with_images.html')))
  end
  let(:page_without_images) do
    Typhoeus::Response.new(code: 200, body: File.open(File.join('spec', 'support', 'page_without_images.html')))
  end

  context 'invalid url provided' do
    let(:url) { '//invalid' }

    it { expect { subject }.to raise_error(RuntimeError, 'URL is invalid!') }
  end

  context 'valid url provided' do
    context 'with images' do
      before { Typhoeus.stub(url).and_return(page_with_images) }

      it do
        expect(File).to receive(:open).exactly(3).times
        subject
      end
    end

    context 'without images' do
      before { Typhoeus.stub(url).and_return(page_without_images) }

      it do
        expect(File).to receive(:open).exactly(0).times
        subject
      end
    end
  end
end
