class Post

    attr_accessor :title

    def initialize(permlink, account)
        api = Radiator::Api.new

        # Retrieve relevant pieces of content from blockchain
        api.get_content(account, permlink) do |content|
            self.title = content.title
        end
    end

end