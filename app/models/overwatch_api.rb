class OverwatchAPI
  include HTTParty
  # See https://github.com/Fuyukai/OWAPI
  base_uri 'https://owapi.net'

  attr_reader :response

  def initialize(battletag:, platform:)
    @battletag = User.parameterize(battletag)
    @platform = platform
    @response = nil
  end

  def profile_url
    URI.escape("/api/v3/u/#{@battletag}/stats?platform=#{@platform}")
  end

  def profile
    @response = self.class.get(profile_url)
    return @response.parsed_response if @response.success?
  end
end
