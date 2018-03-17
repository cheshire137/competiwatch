module UsersHelper
  def settings_box(icon_class:, title:, url:, description:)
    render partial: 'users/settings_box',
           locals: { icon_class: icon_class, title: title,
                     url: url, description: description }
  end
end
