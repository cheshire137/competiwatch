module UsersHelper
  def time_zone_options
    ActiveSupport::TimeZone.all.map do |zone|
      offset = ActiveSupport::TimeZone.seconds_to_utc_offset(zone.utc_offset)
      label = "#{zone.name} (#{offset})"
      [label, zone.name]
    end
  end

  def settings_box(icon_class:, title:, url:, description:)
    render partial: 'users/settings_box',
           locals: { icon_class: icon_class, title: title,
                     url: url, description: description }
  end
end
