
module ICanHazPdf

  # include in order to request generation of pdfs from the icanhazpf service
  # requires that icanhazpdf_api_key is configured in your environment config
  class Client

    # your icanhazpf api key
    def self.api_key
      begin
        Rails.configuration.icanhazpdf_api_key
      rescue
        raise "No API Key Configured"
      end
    end

    def self.default_service_url
      'http://icanhazpdf.lsfapp.com'
    end

    # generate a pdf from the url passed
    def pdf_from_url(full_url)
      uri = URI(full_url)
      params = URI.decode_www_form(uri.query || "") << ['icanhazpdf', ICanHazPdf::Client::api_key]
      uri.query = URI.encode_www_form(params)
      begin
        service_url = Rails.configuration.icanhazpdf_url
      rescue
        service_url = ICanHazPdf::Client.default_service_url
      end
      encoded_url = "#{service_url}/#{URI.encode(uri.to_s).gsub(':', '%3A').gsub('/', '%2F').gsub('?', '%3F').gsub('=', '%3D')}"

      HTTParty.get(encoded_url, :timeout => 10000)
    end

  end

end
