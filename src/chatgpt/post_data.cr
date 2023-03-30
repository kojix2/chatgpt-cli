require "json"

module ChatGPT
  struct PostData
    include JSON::Serializable
    property model : String
    property messages : Array(Hash(String, String))
    property temperature : Float64
    property top_p : Float64
    property n : Int32

    def initialize(
      @model = "gpt-3.5-turbo",
      @messages = [] of Hash(String, String),
      @n = 1,
      @temperature = 1.0,
      @top_p = 1.0
    )
    end

    def count_user_messages
      user_messages.size
    end

    def user_messages
      @messages.select { |msg| msg["role"] == "user" }
    end

    def add_message(role : String, content : String)
      @messages << {"role" => role, "content" => content}
    end
  end
end
