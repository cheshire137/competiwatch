module SeasonsHelper
  def season_switcher_season_path(season)
    if params[:controller] == 'seasons'
      matches_path(battletag: params[:battletag], season: season)
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

  def rank_tier(rank)
    if rank < 1500
      :bronze
    elsif rank < 2000
      :silver
    elsif rank < 2500
      :gold
    elsif rank < 3000
      :platinum
    elsif rank < 3500
      :diamond
    elsif rank < 4000
      :master
    else
      :grandmaster
    end
  end

  def rank_image(rank)
    tier = rank_tier(rank)
    image_tag("tiers/#{tier}.png", alt: tier.to_s.humanize, class: "rank-image rank-#{tier}")
  end
end
