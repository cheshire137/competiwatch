class SetAccountHeroesJob < ApplicationJob
  queue_as :default

  def perform(*args)
    account_id = args.first
    return unless account_id

    account = Account.find_by_id(account_id)
    return unless account

    heroes_by_name = Hero.order_by_name.map { |hero| [hero.name, hero] }.to_h
    stats = account.overwatch_api_stats(heroes_by_name)

    current_account_heroes = account.account_heroes.ordered_by_playtime
    new_top_heroes = stats.top_heroes(limit: AccountHero::MAX_HEROES_PER_ACCOUNT)

    current_account_heroes.each_with_index do |account_hero, i|
      if new_top_heroes[i] && new_top_heroes[i].hero
        account_hero.hero = new_top_heroes[i].hero
        account_hero.seconds_played = new_top_heroes[i].seconds_played
        unless account_hero.save
          errors = account_hero.errors.full_messages.join(', ')
          Rails.logger.error('SetAccountHeroesJob failed to update account-hero: ' \
                             "#{account} - #{errors}")
        end
      else
        unless account_hero.destroy
          errors = account_hero.errors.full_messages.join(', ')
          Rails.logger.error('SetAccountHeroesJob failed to delete account-hero: ' \
                             "#{account} - #{errors}")
        end
      end
    end

    new_top_heroes.drop(current_account_heroes.count).each do |new_top_hero|
      account_hero = AccountHero.new(account: account, hero: new_top_hero.hero,
                                     seconds_played: new_top_hero.seconds_played)
      unless account_hero.save
        errors = account_hero.errors.full_messages.join(', ')
        Rails.logger.error('SetAccountHeroesJob failed to create account-hero: ' \
                           "#{account} - #{errors}")
      end
    end
  end
end
