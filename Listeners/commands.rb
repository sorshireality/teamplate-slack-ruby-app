require 'sinatra/base'
require 'slack-ruby-client'

class API < Sinatra::Base
  require 'ferrum'

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
    db = Database.new
    access_token = db.find_access_token input['team_id']
    client = create_slack_client access_token

    triger_id = input['trigger_id']
    metadata = input['channel_id']

    template = File.read './Components/View/menu.erb'
    view = ERB.new(template).result(binding)

    client.views_open(
        trigger_id: triger_id,
        view: view
    )

    status 200
  end

  get '/render_graph' do
    send_file 'Components/Graph/index.html'
  end

  get '/main.js' do
    send_file 'Components/Graph/main.js'
  end

  get '/style.css' do
    send_file 'Components/Graph/style.css'
  end

  get '/data.json' do
    send_file 'Components/Graph/data.json'
  end

  get %r{/graph_image/(?<ts>\w+)} do
    send_file "/app/#{params[:ts]}_graph.png"
  end

  post '/graph' do
    get_input

    DATA_TO_JSON = {"2021": {"Jun": 8207, "Jul": 12455, "Aug": 10086}, "2022": {"Jul": 1234, "Oct": 5678, "Jan": 9123}}
    File.open('./Components/Graph/data.json', 'w') do |file|
      file.write DATA_TO_JSON.to_json
    end

    browser = Ferrum::Browser.new(
        :browser_path => "/app/.apt/usr/bin/google-chrome"
    )
    browser.go_to("https://#{request.host}/render_graph")

    graph_ts = Time.now.to_i
    browser.screenshot(path: "/app/#{graph_ts}_graph.png")

    db = Database.new
    access_token = db.find_access_token input['team_id']
    client = create_slack_client access_token

    host = request.host
    template = File.read './Components/View/graph.erb'
    view = ERB.new(template).result(binding)

    client.views_open(
        trigger_id: input['trigger_id'],
        view: view
    )

    File.delete "./Components/Graph/result.png"
    File.delete "./Components/Graph/data.json"

    status 200
  end
end
