class API < Sinatra::Base
  post '/interactivity' do
    request_data = Rack::Utils.parse_nested_query(request.body.read)
    payload = JSON.parse(request_data['payload'])
  end
end