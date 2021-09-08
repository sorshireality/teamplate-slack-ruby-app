class API < Sinatra::Base
  post '/events' do
    # The request contains a `type` attribute
    # which can be one of many things, in this case,
    # we only care about `url_verification` events.

    # Grab the body of the request and parse it as JSON
    request_data = JSON.parse request.body.read
    case request_data['type']
    when 'url_verification'
      # When we receive a `url_verification` event, we need to
      # return the same `challenge` value sent to us from Slack
      # to confirm our server's authenticity.
      request_data['challenge']
    else
      # type code here
    end

  end
end