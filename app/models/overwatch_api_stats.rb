class OverwatchAPIStats
  attr_reader :username, :competitive_heroes, :quickplay_heroes,
              :total_competitive_seconds, :total_quickplay_seconds,
              :max_competitive_seconds, :max_quickplay_seconds

  def initialize(data, heroes_by_name: {})
    @username = data['username']
    @competitive_heroes = []
    @quickplay_heroes = []
    @total_competitive_seconds = 0
    @total_quickplay_seconds = 0
    @max_competitive_seconds = 0
    @max_quickplay_seconds = 0

    if stats = data['stats']
      if top_hero_stats = stats['top_heroes']
        if top_hero_stats['competitive']
          @competitive_heroes = top_hero_stats['competitive'].map do |hero_data|
            name = hero_data['hero']
            OverwatchAPIHero.new(hero_data, hero: heroes_by_name[name])
          end

          @competitive_heroes.each do |hero|
            @total_competitive_seconds += hero.seconds_played
            if hero.seconds_played > @max_competitive_seconds
              @max_competitive_seconds = hero.seconds_played
            end
          end
          @competitive_heroes = @competitive_heroes.select(&:any_playtime?).
            sort_by(&:seconds_played).reverse
        end

        if top_hero_stats['quickplay']
          @quickplay_heroes = top_hero_stats['quickplay'].map do |hero_data|
            name = hero_data['hero']
            OverwatchAPIHero.new(hero_data, hero: heroes_by_name[name])
          end

          @quickplay_heroes.each do |hero|
            @total_quickplay_seconds += hero.seconds_played
            if hero.seconds_played > @max_quickplay_seconds
              @max_quickplay_seconds = hero.seconds_played
            end
          end
          @quickplay_heroes = @quickplay_heroes.select(&:any_playtime?).
            sort_by(&:seconds_played).reverse
        end
      end
    end
  end

  def top_heroes(limit: 5)
    heroes = if competitive_heroes.any?
      competitive_heroes
    else
      quickplay_heroes
    end
    heroes[0...limit]
  end

  def tldr_roles
    return @tldr_roles if @tldr_roles
    roles = top_heroes.map(&:role)
    role_counts = {}

    roles.each do |role|
      role_counts[role] ||= 0
      role_counts[role] += 1
    end

    role_counts = role_counts.sort_by { |role, count| -count }.to_h
    @tldr_roles = role_counts.keys.map(&:to_s)
  end

  def tldr
    tldr_roles.map { |role| Hero.pretty_role(role) }.join(' / ')
  end
end
