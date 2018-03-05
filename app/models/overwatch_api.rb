class OverwatchAPI
  include HTTParty
  base_uri 'ow-api.herokuapp.com'

  def initialize(battletag:, region:, platform:)
    @battletag = User.parameterize(battletag)
    @region = region
    @platform = platform
  end

  def profile
    resp = self.class.get("/profile/#{@platform}/#{@region}/#{@battletag}")
    resp.parsed_response if resp.success?
  end

  def stats
    resp = self.class.get("/stats/#{@platform}/#{@region}/#{@battletag}")
    resp.parsed_response if resp.success?
  end
end
