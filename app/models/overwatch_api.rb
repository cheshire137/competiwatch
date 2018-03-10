class OverwatchAPI
  include HTTParty
  base_uri 'ow-api.herokuapp.com'

  def initialize(battletag:, region:, platform:)
    @battletag = User.parameterize(battletag)
    @region = region
    @platform = platform
  end

  def profile_url
    URI.escape("/profile/#{@platform}/#{@region}/#{@battletag}")
  end

  def profile
    resp = self.class.get(profile_url)
    resp.parsed_response if resp.success?
  end

  def stats_url
    URI.escape("/stats/#{@platform}/#{@region}/#{@battletag}")
  end

  def stats
    resp = self.class.get(stats_url)
    resp.parsed_response if resp.success?
  end
end
