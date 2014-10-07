# ICanHazPDF?
Makes using the icanhazpdf service in a Rails app simples

## Installation

Add this line to your application's Gemfile:

    gem 'icanhazpdf', '~> 0.0.3'

## Client

To request a pdf is generated (and sent back to you synchronously) use the
api Client class.

    pdf_response = Icanhazpdf::Client.new.pdf_from_url my_resource_url(resource)

Your api key is automatically appended to the request.
The response is the web response from HTTParty. You can then render this or save
it or do what you like with it. The PDF is in the body of the response - check
the pdf_response.code to ensure it was successful (should be 200).

## Controller

To render a pdf (send the file to the browser) from a url use the renderer module.

    class MyController < ApplicationController
      include Icanhazpdf::Controller::Renderer

      def my_action
        render_pdf_from my_resource_url(resource), 'myfilename.pdf'
      end
    end

The method takes a url from which to render the pdf and a filename - which is sent
to the browser when it saves the file. You can omit the filename and a default
filename is used.

To render a pdf using a previous response from the Client use:

    class MyController < ApplicationController
      include Icanhazpdf::Controller::Renderer

      def my_action
        pdf_response = Icanhazpdf::Client.new.pdf_from_url my_resource_url(resource)

        # do something with the response? save somewhere? upload somewhere?

        render_response_for pdf_response, {filename: 'myfilename.pdf'}
      end
    end

## Authentication

Checks the current request being made is coming from the icanhazpdf service and
has your configured Icanhazapi key in the parameters

    class Api::ApiController < ActionController::Base
      include Icanhazpdf::Controller::Authentication

      before_filter :authenticate

      private

        def authenticate
          head 401 unless authenticate_as_icanhazpdf
        end
    end

### With devise

Checks if the request is either from icanhazpdf or if that fails falls back to
devise authentication


    class Api::ApiController < ActionController::Base
      include Icanhazpdf::Controller::Authentication

      before_filter :authenticate_as_icanhazpdf_or_authenticate_user!
    end
