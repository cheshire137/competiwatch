module TrendsHelper
  def win_rate_color(win_rate)
    if win_rate >= 90
      'rgb(139, 236, 34)'
    elsif win_rate >= 70
      '#c4e556'
    elsif win_rate >= 50
      '#fdde73'
    elsif win_rate >= 30
      '#f0a05b'
    else
      '#de4f3b'
    end
  end
end
