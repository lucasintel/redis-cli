class Redis
  class Connection
    NON_BINARY_SAFE_STRING = '+'
    ERROR                  = '-'
    INTEGER                = ':'
    BINARY_SAFE_STRING     = '$'
    ARRAY                  = '*'
    END                    = "\r\n"

    private getter transport

    def initialize(@transport : Transport)
    end

    def send(value)
      write(value)
      consume
    end

    private def write(value : String)
      transport.write BINARY_SAFE_STRING
      transport.write value.bytesize
      transport.write END
      transport.write value
      transport.write END
    end

    private def write(value : Int)
      transport.write INTEGER
      transport.write value
      transport.write END
    end

    private def write(value : Array(String))
      transport.write ARRAY
      transport.write value.size
      transport.write END

      value.each do |element|
        write(element)
      end
    end

    private def write(value : Nil)
      transport.write BINARY_SAFE_STRING
      transport.write "-1"
      transport.write END
    end

    private def consume : Redis::Protocol::Value
      case transport.read_char
      when NON_BINARY_SAFE_STRING then consume_simple_string
      when ERROR                  then consume_error
      when INTEGER                then consume_integer
      when BINARY_SAFE_STRING     then consume_bulk_string
      when ARRAY                  then consume_array
      else
        Redis::Protocol::Null.new
      end
    end

    private def consume_simple_string : Redis::Protocol::NonBinarySafeString
      value = transport.read_until(END)

      Redis::Protocol::NonBinarySafeString.new(value)
    end

    private def consume_error : Redis::Protocol::Error
      value = transport.read_until(END)

      Redis::Protocol::Error.new(value)
    end

    private def consume_integer : Redis::Protocol::Integer
      value = transport.read_until(END).to_i64

      Redis::Protocol::Integer.new(value)
    end

    private def consume_bulk_string : Redis::Protocol::BinarySafeString | Redis::Protocol::Null
      redis_integer = consume_integer
      return Redis::Protocol::Null.new if redis_integer.value == -1

      string = String.new(redis_integer.value) do |io|
        transport.read_slice(Slice.new(io, redis_integer.value))
        {redis_integer.value, 0}
      end

      transport.skip(END.bytesize)

      Redis::Protocol::BinarySafeString.new(string)
    end

    private def consume_array : Redis::Protocol::RedisArray
      redis_integer = consume_integer
      array = Array(Redis::Protocol::Value).new(redis_integer.value) do
        consume
      end

      Redis::Protocol::RedisArray.new(array)
    end
  end
end
