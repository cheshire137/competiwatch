class OverwatchAPI
  include HTTParty
  base_uri 'ow-api.herokuapp.com'

  attr_reader :response

  def initialize(battletag:, region:, platform:)
    @battletag = User.parameterize(battletag)
    @region = region
    @platform = platform
    @response = nil
  end

  def profile_url
    URI.escape("/profile/#{@platform}/#{@region}/#{@battletag}")
  end

  def profile
    @response = self.class.get(profile_url)
    return @response.parsed_response if @response.success?
  end

  def stats_url
    URI.escape("/stats/#{@platform}/#{@region}/#{@battletag}")
  end

  def stats
    @response = self.class.get(stats_url)
    return @response.parsed_response if @response.success?
  end
end
