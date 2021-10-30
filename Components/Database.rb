require 'pg'
module Database
  def init
    @db = PG.connect(
        host: ENV['HU_POSTGRES_HOST'],
        dbname: ENV['HU_POSTGRES_DBNAME'],
        user: ENV['HU_USER_USER_ENV'],
        password: ENV['HU_POSTGRES_PASS']
    )
  end

  def save_access(team, team_id)
    create_access_table
    remove_if_exist team, team_id
    remember_access team, team_id
  end

  def find_user_access_token(team_id, user_id)
    result = @db.exec "SELECT * FROM oauth_access WHERE team_id like '#{team_id}' and bot_user_id like '#{user_id}'"
    result.values
  end

  def find_team_access_token(team_id)
    result = @db.exec "SELECT * FROM oauth_access WHERE team_id='#{team_id}'"
    result.values
  end

  def remove_if_exist(data, id)
    @db.exec "DELETE FROM oauth_access WHERE team_id like '#{id}' and bot_user_id like '#{data[:bot_user_id]}'"
    true
  end

  def remember_access(data, id)
    @db.exec "INSERT INTO oauth_access(team_id,user_access_token,bot_user_id,bot_access_token) VALUES ('#{id}','#{data[:user_access_token]}','#{data[:bot_user_id]}','#{data[:bot_access_token]}')"
    true
  end

  def create_access_table
    unless get_access_table
      @db.exec "
    create table oauth_access(
    team_id varchar(150),
    user_access_token varchar(150),
    bot_user_id varchar(150),
    bot_access_token varchar(150))
      "
      true
    end
  end

  def get_access_table
    @db.exec "Select * from oauth_access"
    true
  rescue PG::Error
    false
  end

  def find_access_token team_id
    Database.init
    puts 'Получен общий access_token из базы данных'
    Database.find_team_access_token(team_id).first[3]
  end

  module_function(
      :create_access_table,
      :get_access_table,
      :save_access,
      :remember_access,
      :remove_if_exist,
      :find_user_access_token,
      :find_team_access_token,
      :init,
      :find_access_token
  )
end