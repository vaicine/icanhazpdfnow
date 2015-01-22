module Icanhazpdf

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
      'http://icanhazpdf.lsfapp.com/generate_pdf'
    end

    # generate a pdf from the url passed
    def pdf_from_url(full_url, options = {})
      uri = URI(full_url)
      params = URI.decode_www_form(uri.query || "") << ['icanhazpdf', Icanhazpdf::Client::api_key]
      uri.query = URI.encode_www_form(params)
      begin
        service_url = Rails.configuration.icanhazpdf_url
      rescue
        service_url = Icanhazpdf::Client.default_service_url
      end
      encoded_url = "#{service_url}?url=#{URI.encode(uri.to_s).gsub(':', '%3A').gsub('/', '%2F').gsub('?', '%3F').gsub('=', '%3D').gsub('&', '%26')}"
      encoded_url += "&use_wkhtmltopdf=true" if options[:use_wkhtmltopdf]
      encoded_url += "&margin=#{options[:margin]}"
      HTTParty.get(encoded_url, :timeout => 10000)
    end

  end

end
