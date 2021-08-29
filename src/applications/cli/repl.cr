class CLI
  class Repl
    def self.start(redis : Redis, input_stream : IO = STDIN, output_stream : IO = STDOUT)
      new(redis, input_stream, output_stream).start
    end

    def initialize(@redis : Redis, input_stream : IO = STDIN, output_stream : IO = STDOUT)
      @console = Repl::Console.new(prompt: prompt, input_stream: input_stream, output_stream: output_stream)
    end

    def start
      @console.on_input do |input|
        command = Redis::CommandParser.call(input)
        future = @redis.execute(command)

        Redis::ResultFormatter.format(future)
      end

      @console.run
    end

    private def prompt
      String.build do |io|
        io << @redis.host
        io << ':'
        io << @redis.port
        if @redis.database
          io << '['
          io << @redis.database
          io << ']'
        end
        io << '>'
        io << ' '
      end
    end
  end
end
