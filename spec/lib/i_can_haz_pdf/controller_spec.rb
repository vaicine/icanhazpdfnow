require 'spec_helper'

describe "ICanHazPdf::Controller::Renderer" do

  class DummyRailsController
    include ICanHazPdf::Controller::Renderer
  end

  let(:url) { 'http://google.com' }
  let(:filename) { 'ascreenshot.pdf' }
  let(:http_response) { double('response') }
  let(:client) { double('client') }
  let(:http_status) { 200 }
  let(:http_body) { "pdf content" }

  before(:each) do
    allow(ICanHazPdf::Client).to receive(:new).and_return(client)
    allow(client).to receive(:pdf_from_url).and_return(http_response)
    allow(http_response).to receive(:code).and_return http_status
    allow(http_response).to receive(:body).and_return http_body
    allow(subject).to receive(:send_data)
  end

  subject { DummyRailsController.new }

  describe 'rendering a pdf from a url' do

    it 'creates a client to request the pdf' do
      expect(ICanHazPdf::Client).to receive(:new)
      subject.render_pdf_from url, filename
    end

    it 'requests the pdf from the client supplying the url' do
      expect(client).to receive(:pdf_from_url).with(url)
      subject.render_pdf_from url, filename
    end

    it 'calls render response with the output of the client and the filename supplied' do
      expect(subject).to receive(:render_response_for).with(http_response, {filename: filename})
      subject.render_pdf_from url, filename
    end

    context 'no filename supplied' do
      it 'calls render response with the output of the client and no options' do
        expect(subject).to receive(:render_response_for).with(http_response, {})
        subject.render_pdf_from url
      end
    end
  end

  describe 'rendering the response from the client' do

    it "sends the file using the controller's send data method specifying file type and name" do
      expect(subject).to receive(:send_data).with(http_response, {filename: filename, type: :pdf})
      subject.render_response_for http_response, {filename: filename}
    end

    context 'when the pdf response is not success' do
      let(:http_status) { 400 }
      let(:http_body) { "error: no pdf content" }

      it 'raises an error' do
        expect{subject.render_response_for http_response}.to raise_error
      end
    end

    context 'when no filename is supplied' do
      let(:the_date_and_time_now) { DateTime.now }
      before(:each) do
        allow(DateTime).to receive(:now).and_return(the_date_and_time_now)
      end

      it 'uses the current date to provide a filename' do
        expect(subject).to receive(:send_data).with(http_response, {filename: "#{the_date_and_time_now.to_formatted_s(:number)}-icanhaz.pdf", type: :pdf})
        subject.render_response_for http_response
      end
    end
  end

end

describe "ICanHazPdf::Controller::Authentication" do

  class DummyRailsController
    include ICanHazPdf::Controller::Authentication
  end

  subject { DummyRailsController.new }

  let(:the_api_key) { '34765236754673256735' }

  before(:each) do
    allow(ICanHazPdf::Client).to receive(:api_key).and_return(the_api_key)
    allow(subject).to receive(:params).and_return(params)
  end

  describe 'authenticating that a request is from icanhazpdf' do

    context 'request params collection includes the api key' do
      let(:params) { {icanhazpdf: the_api_key} }

      it 'returns true' do
        expect(subject.authenticate_as_icanhazpdf).to eq(true)
      end
    end

    context 'request params collection does not include the icanhazpdf parameter' do
      let(:params) { {} }

      it 'returns false' do
        expect(subject.authenticate_as_icanhazpdf).to eq(false)
      end
    end

    context 'request params has an invalid api key' do
      let(:params) { {icanhazpdf: '374636754365436'} }

      it 'returns false' do
        expect(subject.authenticate_as_icanhazpdf).to eq(false)
      end
    end
  end

  describe 'authenticate request is either from icanhazpdf or fall back to devise' do

    context 'request is from icanhazpdf' do
      let(:params) { {icanhazpdf: the_api_key} }

      it 'returns true' do
        expect(subject.authenticate_as_icanhazpdf_or_authenticate_user!).to eq(true)
      end
    end

    context 'request is not from icanhazpdf' do
      let(:params) { {} }

      it 'falls back to devise' do
        expect(subject).to receive(:authenticate_user!).and_return(false)
        expect(subject.authenticate_as_icanhazpdf_or_authenticate_user!).to eq(false)
      end
    end
  end
end
