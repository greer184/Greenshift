class ContentController < ApplicationController

  # This is the overall display for Content
  def index
    @recent_author = Relationship.recent_author('greer184', 200)
    @recent_vote = Relationship.recent_upvote('greer184', 200)
    @max_vote = Relationship.max_upvote('greer184', 200)
    @recent_resteem = Relationship.recent_resteem('qfilter', 1000)
  end

end
