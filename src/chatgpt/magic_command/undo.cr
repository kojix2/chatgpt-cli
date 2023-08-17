module ChatGPT
  class MagicCommand
    def undo
      undo(1)
      @total_tokens = -1
      true
    end

    def undo(n)
      number_of_user_messages = data.count_user_messages
      n = [n.to_i, number_of_user_messages].min
      n.times do
        data.messages.pop # response
        data.messages.pop # query
      end
      puts "Undo #{n == 1 ? "last" : n} messages"._colorize(:warning)
      @total_tokens = -1
      true
    end
  end
end
