module SeasonsHelper
  def season_switcher_season_path(season)
    if params[:controller] == 'stats'
      if params[:battletag]
        matches_path(battletag: params[:battletag], season: season)
      else
        all_accounts_stats_path(season)
      end
    else
      url_with(season: season)
    end
  end

  def hero_bar_width(hero_match_count, max_hero_match_count, total_match_count)
    hero_percent = (hero_match_count.to_f / total_match_count) * 100
    max_percent = (max_hero_match_count.to_f / total_match_count) * 100
    percent = (hero_percent / max_percent) * 100
    percent + 2
  end

  def rank_image(rank, classes: '')
    tier = Match.rank_tier(rank)
    image_tag("tiers/#{tier}.png", alt: tier.to_s.humanize, class: "rank-image rank-#{tier} #{classes}")
  end
end
