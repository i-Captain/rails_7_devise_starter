class ApplicationController < ActionController::Base
  around_action :switch_locale
  add_flash_types :danger, :success, :warning

  def switch_locale(&action)
    locale = params[:locale] || I18n.default_locale
    I18n.with_locale(locale, &action)
  end
end
