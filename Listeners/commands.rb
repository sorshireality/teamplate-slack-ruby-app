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

  post '/who_am_i' do
    get_input
    Helper.displayUserInfo input['team_id'], input['user_id'], input['channel_id']
    status 200
  end

  post '/menu' do
    get_input
    Database.init
    access_token = Database.find_access_token input['team_id']
    client = create_slack_client access_token

    triger_id = input['trigger_id']
    metadata = input['channel_id']

    template = File.read './Components/View/menu.erb'
    view = ERB.new(template).result(binding)

    client.views_open(
        trigger_id: triger_id,
        view: view
    )
    return true
  end
end
