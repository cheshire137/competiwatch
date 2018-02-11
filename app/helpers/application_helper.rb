module ApplicationHelper
  def url_with(options = {})
    url_for(params.permit(:battletag, :season).merge(options))
  end
end
