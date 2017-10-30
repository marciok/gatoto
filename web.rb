require 'sinatra'
require 'sinatra/base'
require 'i18n'
require 'i18n/backend/fallbacks'
require 'rack'
require 'rack/contrib'
require 'sendgrid-ruby'

use Rack::Locale

configure do
  I18n::Backend::Simple.send(:include, I18n::Backend::Fallbacks)
  I18n.load_path = Dir[File.join(settings.root, 'locales', '*.yml')]
  I18n.backend.load_translations
end

class Gatoto < Sinatra::Base
  include SendGrid
  $sg = SendGrid::API.new(api_key: ENV['SENDGRID_API_KEY'])

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

  post '/subscribe' do
    email = params[:email]
    return 404 if email == '' || email.nil?

    register_mail(email)
    @alert = 'Email registered!'
    haml :index
  end

  def register_mail(mail)
    from = Email.new(email: 'adopt1student@donotreply.com')
    subject = 'Novo cadastro'
    to = Email.new(email: 'adopt1student@gmail.com')
    content = Content.new(type: 'text/plain', value: "Novo email registrado #{mail}")
    mail = Mail.new(from, subject, to, content)
    response = $sg.client.mail._('send').post(request_body: mail.to_json)
    puts "Registration response #{response.status_code}"
  end
end
