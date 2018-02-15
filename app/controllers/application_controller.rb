class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  protected

  def set_streaks(matches)
    matches_by_id = matches.map { |match| [match.id, match] }.to_h
    matches.each do |match|
      match.win_streak = Match.get_win_streak(match, matches_by_id)
      match.loss_streak = Match.get_loss_streak(match, matches_by_id)
    end
  end

  def set_season
    @season = params[:season].to_i
  end

  def set_oauth_account
    battletag = User.battletag_from_param(params[:battletag])
    @oauth_account = OauthAccount.find_by_battletag(battletag)
    unless @oauth_account
      return render(file: Rails.root.join('public', '404.html'), status: :not_found)
    end
    unless @oauth_account.user == current_user
      render file: Rails.root.join('public', '404.html'), status: :not_found
    end
  end
end
