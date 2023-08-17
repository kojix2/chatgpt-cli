module ChatGPT
  class MagicCommand
    def shift
      shift(1)
      @total_tokens = -1
      true
    end

    def shift(n)
      number_of_user_messages = data.count_user_messages
      n = [n.to_i, number_of_user_messages].min
      n.times do
        data.messages.shift # query
        data.messages.shift # response
      end
      puts "Shift #{n} messages"._colorize(:warning)
      @total_tokens = -1
      true
    end
  end
end
