require 'sinatra/base'
require 'slack-ruby-client'

class API < Sinatra::Base

  attr_accessor :access_token
  attr_accessor :input

  def get_input
    self.input = Rack::Utils.parse_nested_query(request.body.read)
    puts 'Получена входная строка'
  end

  get '/test' do
    status 302
    redirect "https://slack.com/oauth/v2/authorize?&client_id=#{SLACK_CONFIG[:slack_client_id]}&scope=app_mentions:read,channels:history,channels:read,chat:write,chat:write.customize,commands,files:write,groups:history,groups:read,im:history,im:read,mpim:read,users.profile:read,users:read&user_scope=channels:history,channels:read&redirect_uri=#{SLACK_CONFIG[:redirect_uri]}"
  end
end
