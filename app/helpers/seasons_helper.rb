module SeasonsHelper
  def season_switcher_season_path(season)
    if params[:controller] == 'trends'
      if params[:battletag]
        trends_path(season, params[:battletag])
      else
        all_accounts_trends_path(season)
      end
    else
      url_with(season: season)
    end
  end

  def hero_bar_width(hero_match_count, max_hero_match_count, total_match_count)
    hero_percent = (hero_match_count.to_f / total_match_count) * 100
    max_percent = (max_hero_match_count.to_f / total_match_count) * 100
    percent = (hero_percent / max_percent) * 100
    return 100 if percent >= 100
    percent + 2
  end

  def rank_image(rank, classes: '', outer_classes: '')
    outer_classes += ' d-inline-block tooltipped-n tooltipped'
    content_tag(:span, class: outer_classes, 'aria-label' => rank.to_s) do
      rank_tier_image(Match.rank_tier(rank), classes: classes)
    end
  end

  def rank_tier_image(rank_tier, classes: '', id: nil)
    image_tag("tiers/#{rank_tier.to_s.underscore}.png",
              alt: rank_tier.to_s.humanize, id: id,
              class: "rank-image rank-#{rank_tier} #{classes}")
  end
end
