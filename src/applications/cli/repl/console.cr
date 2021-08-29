require "fancyline"

class CLI
  class Repl
    class Console
      HISTORY_FILE = "#{Path.home}/.crystal_redis_cli_history"

      def initialize(@prompt : String, input_stream : IO = STDIN, output_stream : IO = STDOUT)
        @console = Fancyline.new(input_stream, output_stream)
        load_history
      end

      def on_input(&block : String -> String) : Nil
        @on_input_callback = block
      end

      def run
        while input = ask_for_input
          next if input.blank?

          if callback = @on_input_callback
            write callback.call(input)
          end
        end
      rescue Fancyline::Interrupt
      ensure
        save_history
      end

      private def ask_for_input
        @console.readline(@prompt)
      end

      private def write(value)
        @console.output.puts(value)
      end

      private def load_history
        return unless File.exists?(HISTORY_FILE)

        File.open(HISTORY_FILE, "r") do |io|
          @console.history.load(io)
        end
      end

      private def save_history
        File.open(HISTORY_FILE, "w") do |io|
          @console.history.save(io)
        end
      end
    end
  end
end
