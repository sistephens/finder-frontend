class ApplicationController < ActionController::Base
  include Slimmer::Headers
  include Slimmer::Template
  slimmer_template "header_footer_only"

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  helper :application
  rescue_from GdsApi::HTTPNotFound, with: :error_not_found

private

  def error_503(exception)
    error(503, exception)
  end

  def error(status_code, exception = nil)
    if exception
      GovukError.notify(exception)
    end

    render status: status_code, plain: "#{status_code} error"
  end

  def finder_base_path
    "/#{finder_slug}"
  end

  def finder_slug
    params[:slug]
  end

  def error_not_found
    render status: :not_found, plain: "404 error not found"
  end
end
