require "option_parser"
require "./cli/**"

class CLI
  @host : String = Redis::DEFAULT_HOST
  @port : Int32 = Redis::DEFAULT_PORT
  @password : String?
  @database : String?

  def initialize(args = ARGV)
    OptionParser.parse(args) do |parser|
      parser.on("-h <hostname>", "Server hostname (default: #{Redis::DEFAULT_HOST})") do |host|
        @host = host
      end

      parser.on("-p <port>", "Server port (default: #{Redis::DEFAULT_PORT})") do |port|
        @port = port.to_i
      end

      parser.on("-a <password>", "Password to use when connecting to the server") do |password|
        @password = password
      end

      parser.on("-n <db>", "Database number.") do |database|
        @database = database
      end
    end

    @redis = Redis.new(
      host: @host,
      port: @port,
      password: @password,
      database: @database,
    )
  end

  def run
    CLI::Repl.start(@redis)
  end
end
