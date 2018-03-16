class MatchHero < ApplicationRecord
  self.table_name = 'heroes_matches'

  belongs_to :match, required: false
end
