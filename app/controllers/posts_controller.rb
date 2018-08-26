class PostsController < ApplicationController

  # This is the overall display for all content
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
    @options.map! { |op| Post.find_by(permlink: op) }
    @options.reject! { |op| op.nil? }
  end

  # This is the display for a single piece of content
  def show
    @post = Post.find(params[:id])
  end

end
