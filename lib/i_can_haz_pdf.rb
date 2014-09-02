require "i_can_haz_pdf/version"

module ICanHazPdf

  # include in order to request generation of pdfs from the icanhazpf service
  # requires that icanhazpdf_api_key is configured in your environment config
  module Client
    # your icanhazpf api key
    def self.api_key
      Rails.configuration.icanhazpdf_api_key
    end

    # generate a pdf from the url passed
    def pdf_from_url(full_url)
      uri = URI(full_url)
      params = URI.decode_www_form(uri.query || "") << ['icanhazpdf', ICanHazPdf::Client::api_key]
      uri.query = URI.encode_www_form(params)
      encoded_url = "#{Rails.configuration.icanhazpdf_url}/#{URI.encode(uri.to_s).gsub(':', '%3A').gsub('/', '%2F').gsub('?', '%3F')}"
      HTTParty.get(encoded_url, :timeout => 10000)
    end
  end

  # include in a controller and use to render pdfs or authenticate requests
  # are from icanhazpf
  module Renderer
    # send the pdf to the user if its a valid file
    # optionally pass the filename in the options hash
    # raises an exception if something went wrong
    def render_response_for(pdf_response, options = {})
      raise "Failed to generate pdf:\nCode: #{pdf_response.code}\nBody:\n#{pdf_response.body}" unless pdf_response.code == 200

      filename = options.has_key?(:filename) ? options[:filename] : "#{DateTime.now.to_formatted_s(:number)}-icanhaz.pdf"
      send_data pdf_response, :filename => filename, :type => :pdf
    end

    # true if the request includes the correct icanhazpdf api key
    def authenticate_as_icanhazpdf
      return false unless params[:icanhazpdf].present?
      return params[:icanhazpdf] == ICanHazPdf::Client::api_key
    end

    # attemps to authenticate as icanhazpdf and falls back to devise
    def authenticate_as_icanhazpdf_or_authenticate_user!
      authenticate_as_icanhazpdf || authenticate_user!
    end
  end

end
