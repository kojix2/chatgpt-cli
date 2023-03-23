require "json"

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
end
