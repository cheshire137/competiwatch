class OverwatchAPIProfile
  attr_reader :star_url, :avatar_url, :level, :rank, :rank_url, :level_url

  def initialize(data)
    @star_url = data['star'].presence
    @star_url += 'png' if @star_url && @star_url.ends_with?('.')

    @avatar_url = data['portrait'].presence
    @avatar_url += 'png' if @avatar_url && @avatar_url.ends_with?('.')

    @level = data['level']
    @level_url = data['levelFrame'].presence
    @level_url += 'png' if @level_url && @level_url.ends_with?('.')

    if competitive = data['competitive']
      @rank = competitive['rank']
      @rank_url = competitive['rank_img']
    end
  end
end
