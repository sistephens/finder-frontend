require 'email_alert_signup_api'

class EmailAlertSubscriptionsController < ApplicationController
  layout "finder_layout"
  protect_from_forgery except: :create

  def new
    @signup = signup_presenter
  end

  def create
    if valid_choices?
      redirect_to email_alert_signup_api.signup_url
    else
      @signup = signup_presenter
      @error_message = "Please choose an email alert"
      render action: :new
    end
  end

private

  def valid_choices?
    available_choices.blank? || chosen_options.present?
  end

  def signup_presenter
    @signup_presenter ||= SignupPresenter.new(content)
  end

  def content
    @content ||= Services.content_store.content_item(request.path)
  end

  def finder
    FinderPresenter.new(Services.content_store.content_item(finder_base_path))
  end

  def finder_format
    finder.filter['document_type']
  end

  def available_choices
    content['details']['email_signup_choice']
  end

  def email_alert_signup_api
    EmailAlertSignupAPI.new(
      email_alert_api: Services.email_alert_api,
      attributes: email_signup_attributes,
      subscription_list_title_prefix: content['details']['subscription_list_title_prefix'],
      available_choices: available_choices,
      filter_key: content['details']['email_filter_by'],
    )
  end

  def chosen_options
    params.permit("filter" => [])['filter']
  end

  def email_signup_attributes
    {
      "format" => [finder_format],
      "filter" => chosen_options,
    }
  end
end
