module Helper
  def displayUserInfo(team_id, user_id, channel_id)
    Database.init
    client = create_slack_client(Database.find_access_token team_id)
    message = client.users_profile_get(
        user: user_id
    ).to_s
    blocks =
        [
            'type' => 'section',
            'text' => {
                'type' => 'mrkdwn',
                'text' => message
            }
        ]
    client.chat_postMessage(
        channel: channel_id,
        blocks: blocks.to_json
    )
  end

  module_function(
      :displayUserInfo
  )
end