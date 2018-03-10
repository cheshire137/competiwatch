class OverwatchAPIProfile
  attr_reader :star_url, :portrait_url, :quickplay_time, :competitive_time,
              :level, :competitive_wins, :competitive_games, :username,
              :quickplay_wins, :rank, :rank_url, :level_url

  def initialize(data)
    @star_url = data['star'].presence
    @star_url += 'png' if @star_url && @star_url.ends_with?('.')

    @portrait_url = data['portrait'].presence
    @portrait_url += 'png' if @portrait_url && @portrait_url.ends_with?('.')

    if playtime = data['playtime']
      @quickplay_time = playtime['quickplay']
      @competitive_time = playtime['competitive']
    end

    @level = data['level']
    @level_url = data['levelFrame'].presence
    @level_url += 'png' if @level_url && @level_url.ends_with?('.')

    if competitive = data['competitive']
      @rank = competitive['rank']
      @rank_url = competitive['rank_img']
    end

    if games = data['games']
      if comp_games = games['competitive']
        @competitive_wins = comp_games['won']
        @competitive_games = comp_games['played']
      end

      if quickplay = games['quickplay']
        @quickplay_wins = quickplay['won']
      end
    end
  end

  def competitive_win_percent
    return unless @competitive_wins && @competitive_games
    pct = (@competitive_wins.to_f / @competitive_games) * 100
    pct.round
  end
end
