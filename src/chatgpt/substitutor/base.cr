module ChatGPT
  class Substitutor
    class Base
      def substitute(text, config)
        raise NotImplementedError.new("Do not use #{self.class} directly")
        text
      end
    end
  end
end
