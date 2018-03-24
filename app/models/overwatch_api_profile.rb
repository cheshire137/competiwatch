class OverwatchAPIProfile
  attr_reader :avatar_url, :level, :rank, :level_url

  def initialize(data, region:)
    region_data = data[region]
    return unless region_data

    stats = region_data['stats']
    overall_stats = if (competitive = stats['competitive']).present?
      competitive['overall_stats']
    elsif (quickplay = stats['quickplay']).present?
      quickplay['overall_stats']
    end

    if overall_stats
      @rank = overall_stats['comprank']
      @level_url = overall_stats['rank_image']
      @avatar_url = overall_stats['avatar']
      @level = (overall_stats['prestige'] * 100) + overall_stats['level']
    end
  end
end
