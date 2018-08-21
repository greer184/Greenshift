class Post < ApplicationRecord

    attr_accessor :title
    attr_accessor :url

    def initialize(permlink, account)
        api = Radiator::Api.new

        # Retrieve relevant pieces of content from blockchain
        api.get_content(account, permlink) do |content|
            self.title = content.title
            self.url = "https://steemit.com" + content.url
        end
    end

end