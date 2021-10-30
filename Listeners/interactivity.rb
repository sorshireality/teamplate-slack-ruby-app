class API < Sinatra::Base
  post '/interactivity' do
    request_data = Rack::Utils.parse_nested_query(request.body.read)
    payload = JSON.parse(request_data['payload'])
    case payload['view']['callback_id']
    when 'menu'
      case payload['actions'].first['action_id']
      when 'display_user_info'
        Helper.displayUserInfo payload['user']['team_id'], payload['user']['id'], payload['view']['private_metadata']
        status 200
      else
        status 404
      end
    else
      status 404
    end
  end
end