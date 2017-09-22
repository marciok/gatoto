require 'sinatra'
require 'sinatra/base'
require 'i18n'
require 'i18n/backend/fallbacks'
require 'rack'
require 'rack/contrib'

use Rack::Locale

configure do
  I18n::Backend::Simple.send(:include, I18n::Backend::Fallbacks)
  I18n.load_path = Dir[File.join(settings.root, 'locales', '*.yml')]
  I18n.backend.load_translations
end

class Gatoto < Sinatra::Base

  before do
    @host = request.host.gsub('www.', '')
    accept_language = @env["HTTP_ACCEPT_LANGUAGE"]
    return I18n.locale = 'en' unless accept_language
    locale = accept_language[0,2]
    locale = 'pt' if locale == 'pt-br'
    locale = 'en' if locale != 'pt'
    I18n.locale = locale
  end

  get '/' do
    haml :index
  end
end
