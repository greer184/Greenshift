class Relationship

    SECONDS_IN_WEEK = 604800

    def self.recent_author(account, depth)
        api = Radiator::Api.new

        # Grab most recent N operations for the author and cycle through them
        result = nil
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
                
            end
        end
        result
    end

    def self.recent_upvote(account, depth)
        api = Radiator::Api.new

        # Grab most recent N operations for the author and cycle through them
        result = nil
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
                result = op.permlink

            end
        end
        result
    end

    def self.max_upvote(account, depth)
        api = Radiator::Api.new

        # Grab most recent N operations for the author and cycle through them
        result = nil
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
                result = op.permlink
                max_weight = op.weight

            end
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

        # Repeat the process for the next author
        result = nil
        max_weight = 0
        api.get_account_history(author, -1, depth) do |data|
            data.each do |i, item|

                # Just our normal process of filtering blockchain info
                type, op = item.op
                age = Time.now - DateTime.parse(item.timestamp + 'Z').to_time
        
                # Filtering of type, author, and age
                next unless type == "comment"
                next unless op.parent_author.empty?
                next if age > SECONDS_IN_WEEK
                result = op.permlink

            end
        end
        result
    end

end