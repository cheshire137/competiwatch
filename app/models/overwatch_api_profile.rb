class OverwatchAPIProfile
  attr_reader :avatar_url

  def initialize(data)
    region_data = data.values.detect { |data| data.is_a?(Hash) && data.key?('stats') }
    return unless region_data

    stats = region_data['stats']
    overall_stats = if (competitive = stats['competitive']).present?
      competitive['overall_stats']
    elsif (quickplay = stats['quickplay']).present?
      quickplay['overall_stats']
    end

    if overall_stats
      @avatar_url = overall_stats['avatar']
    end
  end
end
