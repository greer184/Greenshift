class Relationship

    SECONDS_IN_WEEK = 604800

    def self.recent_author(account, depth)
        api = Radiator::Api.new

        # Grab most recent N operations for the author and cycle through them
        result = nil
        title = nil
        api.get_account_history(account, -1, depth) do |data|
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
                title = op.title
            end
        end

        # Store new post if it doesn't exist
        if Post.find_by(permlink: result).nil?
            Post.create(permlink: result, author: account, title: title)
        end
        result
    end

    def self.recent_upvote(account, depth)
        api = Radiator::Api.new

        # Grab most recent N operations for the author and cycle through them
        result = nil
        author = nil
        title = nil
        api.get_account_history(account, -1, depth) do |data|
            data.each do |i, item|

                # Grab the operation information
                type, op = item.op

                # Get the timestamp of content
                age = Time.now - DateTime.parse(item.timestamp + 'Z').to_time
        
                # Filter by vote type, timestamp, and make sure author is different
                next unless type == "vote"
                next unless op.author != account
                next if age > SECONDS_IN_WEEK

                # Filter by vote weighting
                next if op.weight <= 0

                # Verify this is top-level piece of content
                api.get_content(op.author, op.permlink) do |content|
                    next unless content.parent_author.empty?
                    result = op.permlink
                    author = op.author
                    title = content.title
                end

            end
        end

        # Store new post if it doesn't exist
        if Post.find_by(permlink: result).nil?
            Post.create(permlink: result, author: author, title: title)
        end
        result
    end

    def self.max_upvote(account, depth)
        api = Radiator::Api.new

        # Grab most recent N operations for the author and cycle through them
        result = nil
        author = nil
        title = nil
        max_weight = 0
        api.get_account_history(account, -1, depth) do |data|
            data.each do |i, item|

                # Grab the operation information
                type, op = item.op

                # Get the timestamp of content
                age = Time.now - DateTime.parse(item.timestamp + 'Z').to_time
        
                # Filter by vote type, timestamp, and make sure author is different
                next unless type == "vote"
                next unless op.author != account
                next if age > SECONDS_IN_WEEK

                # Filter by vote weighting
                next if op.weight < max_weight

                # Verify this is top-level piece of content
                api.get_content(op.author, op.permlink) do |content|
                    next unless content.parent_author.empty?
                    result = op.permlink
                    max_weight = op.weight
                    author = op.author
                    title = content.title
                end

            end
        end
        
        # Store new post if it doesn't exist
        if Post.find_by(permlink: result).nil?
            Post.create(permlink: result, author: author, title: title)
        end
        result
    end

    def self.recent_resteem(account, depth)
        api = Radiator::Api.new

        # Grab most recent N operations for the author and cycle through them
        author = nil
        max_weight = 0
        api.get_account_history(account, -1, depth) do |data|
            data.each do |i, item|

                # Grab the operation information
                type, op = item.op
        
                # Filter by vote type -> reblog requires json
                next unless type == "custom_json"
                
                # Make sure this is reblog and grab author
                json = JSON.parse(op.json)
                next unless json[0] == "reblog"
                author = json[1]['author']
            end
        end

        # Now that we have author, get the most recent post
        self.recent_author(author, depth)
    end

    def self.largest_contributor(account, depth)
        api = Radiator::Api.new

        # Grab most recent N operations for the author and cycle through them
        result = nil
        author = nil
        title = nil
        contribution = 0
        api.get_account_history(account, -1, depth) do |data|
            data.each do |i, item|

                # Grab the operation information
                type, op = item.op

                # Get the timestamp of content
                age = Time.now - DateTime.parse(item.timestamp + 'Z').to_time
        
                # Filter by vote type, timestamp, and make sure author is different
                next unless type == "vote"
                next unless op.author != account
                next if age > SECONDS_IN_WEEK

                # We now need to grab this piece of content to get all votes on it
                api.get_content(op.author, op.permlink) do |content|

                    # Make sure this content is a top level post
                    next unless content.parent_author.empty?
                    content.active_votes do |votes|
                        votes.each do |v|

                            # Find the vote of the account and measure
                            next unless account == v.voter
                            if v.weight > contribution
                                contribution = v.weight
                                result = op.permlink
                                author = op.author
                                title = content.title
                            end
                        end
                    end
                end
            end
        end

        # Store new post if it doesn't exist
        if Post.find_by(permlink: result).nil?
            Post.create(permlink: result, author: author, title: title)
        end
        result
    end
end