require 'pg'

class Database
  attr_accessor :db

  TABLES = [
      'oauth_access',
  ]

  def initialize
    self.db = PG.connect(
        host: ENV['HU_POSTGRES_HOST'],
        dbname: ENV['HU_POSTGRES_DBNAME'],
        user: ENV['HU_USER_USER_ENV'],
        password: ENV['HU_POSTGRES_PASS']
    )
    TABLES.each do |table_name|
      unless get_table_by_name table_name
        send("create_#{table_name}_table")
      end
    end
  end

  def save_access(team, team_id)
    remove_if_exist team, team_id
    remember_access team, team_id
  end

  def find_user_access_token(team_id, user_id)
    db.exec("SELECT * FROM oauth_access WHERE team_id like '#{team_id}' and bot_user_id like '#{user_id}'").values
  end

  def find_team_access_token(team_id)
    db.exec("SELECT * FROM oauth_access WHERE team_id='#{team_id}'").values
  end

  def remove_if_exist(data, id)
    db.exec "DELETE FROM oauth_access WHERE team_id like '#{id}' and bot_user_id like '#{data[:bot_user_id]}'"
    true
  end

  def remember_access(data, id)
    db.exec "INSERT INTO oauth_access(team_id,user_access_token,bot_user_id,bot_access_token) VALUES ('#{id}','#{data[:user_access_token]}','#{data[:bot_user_id]}','#{data[:bot_access_token]}')"
    true
  end

  def create_oauth_access_table
    db.exec "
    create table oauth_access(
    team_id varchar(150),
    user_access_token varchar(150),
    bot_user_id varchar(150),
    bot_access_token varchar(150))
      "
      true
  end

  def find_access_token team_id
    self.find_team_access_token(team_id).first[3]
  end

  def get_table_by_name(table_name)
    begin
      result = db.exec "Select * from #{table_name}"
      result.values
      true
    rescue PG::Error
      false
    end
  end
end