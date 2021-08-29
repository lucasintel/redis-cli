require "socket"

class Redis
  class Socket < Redis::Transport
    def initialize(host, port, connect_timeout = nil, timeout = nil)
      @socket = TCPSocket.new(host, port, connect_timeout: connect_timeout)
      if timeout
        @socket.read_timeout = timeout
        @socket.write_timeout = timeout
      end
    end

    def write(value) : Nil
      normalise_exceptions do
        @socket.print(value)
      end
    end

    def read_until(delimiter : String) : String
      normalise_exceptions do
        unless line = @socket.gets(delimiter, chomp: true)
          raise Transport::Error.new("could not read from the socket")
        end

        line
      end
    end

    def read_char : Char
      normalise_exceptions do
        unless char = @socket.read_char
          raise Transport::Error.new("could not read from the socket")
        end

        char
      end
    end

    def read_slice(slice : Slice) : Int32
      normalise_exceptions do
        @socket.read_fully(slice)
      end
    end

    def skip(bytes_count : Int) : Nil
      normalise_exceptions do
        @socket.skip(bytes_count)
      end
    end

    private def normalise_exceptions
      yield
    rescue ex : IO::Error | Socket::Error
      raise Transport::Error.new("#{ex.class}: #{ex.message}")
    rescue ex : IO::TimeoutError
      raise Transport::TimeoutError.new(ex.message)
    end
  end
end
