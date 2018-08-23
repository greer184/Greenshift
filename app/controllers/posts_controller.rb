class PostsController < ApplicationController

  # This is the overall display for Content
  def index
    author = 'greer184'
    @options = [
      Relationship.recent_author(author, 200),
      Relationship.recent_upvote(author, 200),
      Relationship.max_upvote(author, 200),
      Relationship.recent_resteem(author, 1000),
      Relationship.largest_contributor(author, 200),
    ]
    @options.uniq!
  end

end
