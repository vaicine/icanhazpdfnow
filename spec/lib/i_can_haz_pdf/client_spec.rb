require 'spec_helper'
require 'httparty'

describe 'ICanHazPdf::Client' do

  let(:a_url) { "http://a.url.to/generate_a_pdf_from?with=querystring" }
  subject { ICanHazPdf::Client.new }

  describe 'generating a pdf from' do
    let(:http_response) { double("http_response") }
    let(:icanhazpdf_service_url) { 'http://icanhazpdf.service.url' }
    let(:rails_config) { double 'rails_config' }
    let(:icanhazpdf_api_key) { 'abcderfgkjdjhjdh1376375' }

    before(:each) do
      Rails = class_double('Rails').as_stubbed_const
      allow(rails_config).to receive(:icanhazpdf_api_key).and_return(icanhazpdf_api_key)
      allow(rails_config).to receive(:icanhazpdf_url).and_return(icanhazpdf_service_url)
      allow(Rails).to receive(:configuration).and_return(rails_config)
      allow(HTTParty).to receive(:get).and_return(http_response)
    end

    describe 'building the request for icanhazpdf' do

      it 'uses the icanhazpdf service url from the rails config' do
        expect(HTTParty).to receive(:get).with(include(icanhazpdf_service_url), be_an(Hash))
        @result = subject.pdf_from_url a_url
      end

      it 'appends the api key on the request to icanhazpdf' do
        expect(HTTParty).to receive(:get).with(include("icanhazpdf%3D#{icanhazpdf_api_key}"), be_an(Hash))
        @result = subject.pdf_from_url a_url
      end

      it 'url encodes the address of the page to create a pdf from' do
        expect(HTTParty).to receive(:get).with(include("http%3A%2F%2Fa.url.to%2Fgenerate_a_pdf_from%3Fwith%3Dquerystring"), be_an(Hash))
        @result = subject.pdf_from_url a_url
      end

      it 'sets the timeout to 10 seconds' do
        expect(HTTParty).to receive(:get).with(be_a(String), hash_including(timeout: 10000))
        @result = subject.pdf_from_url a_url
      end

      context 'no icanhazpdf api key in the config' do
        before(:each) do
          allow(rails_config).to receive(:icanhazpdf_api_key).and_raise("Undefined config value")
        end

        it 'raises an error' do
          expect{subject.pdf_from_url a_url}.to raise_error("No API Key Configured")
        end
      end

      context 'no icanhazpdf service url in the config' do
        before(:each) do
          allow(rails_config).to receive(:icanhazpdf_url).and_raise("Undefined config value")
        end

        it 'uses the default service url' do
          expect(HTTParty).to receive(:get).with(include(ICanHazPdf::Client.default_service_url), be_an(Hash))
          @result = subject.pdf_from_url a_url
        end
      end
    end

    describe 'requests pdf from icanhazpdf' do

      context 'a valid page to generate a pdf from' do
        let(:http_status) { 200 }
        let(:http_body) { "The pdf content" }

        before(:each) do
          allow(http_response).to receive(:status).and_return http_status
          allow(http_response).to receive(:body).and_return http_body
          @result = subject.pdf_from_url a_url
        end

        it 'should return whatever httparty returns as a status' do
          expect(@result.status).to eq(http_status)
        end

        it 'should return whatever httparty returns as the body' do
          expect(@result.body).to eq(http_body)
        end
      end

      context 'an invalid url' do
        it 'should raise an error' do
          expect{subject.pdf_from_url 'an27632&@^&^£%^£?_invalid_url_3746376&^^%$'}.to raise_error
        end
      end

    end

  end
end
