require 'icanhazpdf/client'
require 'active_support/core_ext/date_time/conversions'

module Icanhazpdf

  module Controller
    # include in a controller and use to render pdfs or authenticate requests
    # are from icanhazpf
    module Renderer

      # generate and render a pdf from a url
      def render_pdf_from(url, filename = "", use_wkhtmltopdf = false, margin = "1cm")
        options = {}
        options[:filename] = filename if filename.present?
        render_response_for Icanhazpdf::Client.new.pdf_from_url(url, use_wkhtmltopdf, margin), options
      end

      # send the pdf to the user if its a valid file
      # optionally pass the filename in the options hash
      # raises an exception if something went wrong
      def render_response_for(pdf_response, options = {})
        raise "Failed to generate pdf:\nCode: #{pdf_response.code}\nBody:\n#{pdf_response.body}" unless pdf_response.code == 200

        filename = options.has_key?(:filename) ? options[:filename] : "#{DateTime.now.to_formatted_s(:number)}-icanhaz.pdf"
        send_data pdf_response, :filename => filename, :type => :pdf
      end

    end

    module Authentication
      # true if the request includes the correct Icanhazpdf api key
      def authenticate_as_icanhazpdf
        return false unless params[:icanhazpdf].present?
        return params[:icanhazpdf] == Icanhazpdf::Client::api_key
      end

      # attemps to authenticate as Icanhazpdf and falls back to devise
      def authenticate_as_icanhazpdf_or_authenticate_user!
        authenticate_as_icanhazpdf || authenticate_user!
      end
    end

  end
end
