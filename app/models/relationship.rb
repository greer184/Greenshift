require 'radiator'

class Relationship

    SECONDS_IN_WEEK = 604800

    def recent_author(account, depth)
        api = Radiator::Api.new

        # Grab most recent N operations for the author and cycle through them
        result = nil
        api.get_account_history(author, -1, depth) do |data|
            data.each do |i, item|

                # Grab the operation information
                type, op = item.op

                # Get the timestamp of content
                age = Time.now - DateTime.parse(item.timestamp + 'Z').to_time
        
                # Filter by vote type, timestamp, and make sure author is different
                next unless type == "comment"
                next unless op.parent_author.empty?
                next if age > SECONDS_IN_WEEK
                result = op.permlink
            end
        end
        result
    end

    def recent_upvote(account, depth)
        api = Radiator::Api.new

        # Grab most recent N operations for the author and cycle through them
        result = nil
        api.get_account_history(author, -1, 200) do |data|
            data.each do |i, item|

                # Grab the operation information
                type, op = item.op

                # Get the timestamp of content
                age = Time.now - DateTime.parse(item.timestamp + 'Z').to_time
        
                # Filter by vote type, timestamp, and make sure author is different
                next unless type == "vote"
                next unless op.author != author
                next if age > SECONDS_IN_WEEK
                result = op.permlink
            end
        end
        result
    end

end