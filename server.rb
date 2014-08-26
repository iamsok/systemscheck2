require 'sinatra'
require 'sinatra/reloader'
require 'pry'
require 'csv'

# Acceptance Criteria:

# I can navigate to a page /leaderboard to view the summary of the league. Each team is displayed on
# this page. For each team, I can see how many wins and losses they have.
# [**OPTIONAL CHALLENGE**]Teams are sorted first by the number of wins they have
# (teams with more wins are ranked higher) and second by the number
#  of losses they have (teams with more losses are ranked lower).
#
#
####################################################################
########################## M O D E L S #############################
####################################################################

def read_scores_from
  teams_data = []

  CSV.foreach('scores.csv', headers: true, header_converters: :symbol) do |row|
    teams_data << row.to_hash
  end

  teams_data
end

def get_teamlist(teams_data)
  teams = []

  teams_data.each do |team|
    teams << team[:home_team]
    teams << team[:away_team]
  end

  teams.uniq!
end

def opponents(teams_data, teams)
  stored_team = []
  counter = 0

  teams.each do |team|
    stored_team << {name: team, opponent: [], win: 0, loss: 0}

    teams_data.each do |row|
      if team == row[:home_team]
        stored_team[counter][:opponent] << row[:away_team]
        if row[:home_score] > row[:away_score]
          stored_team[counter][:win] += 1
        elsif row[:home_score] < row[:away_score]
          stored_team[counter][:loss] += 1
        end
      elsif team == row[:away_team]
        stored_team[counter][:opponent] << row[:home_team]
        if row[:away_score] > row[:home_score]
          stored_team[counter][:win] += 1
        elsif row[:home_score] < row[:away_score]
          stored_team[counter][:loss] += 1
        end
      end
    end

    counter += 1
  end

  stored_team
end

p opponents(read_scores_from, get_teamlist(read_scores_from))

####################################################################
###################### R O U T E S #################################
####################################################################

get '/' do
  game_data = read_scores_from
  team_list = get_teamlist(game_data)
  @teams_data = opponents(game_data, team_list)

  erb :view_teams
end

# get '/:team_name' do
#   @opponents = opponents(read_scores_from, get_teamlist(read_scores_from))
#   erb :team_name
# end

