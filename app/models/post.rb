class Post < ApplicationRecord

    def self.get_body(permlink, author) 
        api = Radiator::Api.new

        # Grab the body of post and return it
        api.get_content(author, permlink) do |content|
            return content.body
        end

    end
end