require "./redis/**"

class Redis
  DEFAULT_HOST = "127.0.0.1"
  DEFAULT_PORT = 6379

  getter host : String
  getter port : Int32
  getter database : String?

  def initialize(@host = DEFAULT_HOST, @port = DEFAULT_PORT, @database = nil, password : String? = nil)
    @connection = Redis::Connection.new(
      transport: Redis::Socket.new(host: @host, port: @port)
    )

    authenticate(password) if password
    switch(database) if database
  end

  def execute(command : Redis::Protocol::Command) : Redis::Protocol::Value
    @connection.send(command)
  end

  private def authenticate(password : String)
    @connection.send(["AUTH", password])
  end

  private def switch(database : String)
    @connection.send(["SELECT", database])
  end
end
