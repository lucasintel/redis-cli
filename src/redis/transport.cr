class Redis
  abstract class Transport
    abstract def write(value) : Nil

    abstract def read_until(delimiter : String) : String

    abstract def read_char : Char

    abstract def read_slice(slice : Slice) : Int32

    abstract def skip(bytes_count : Int)

    class Error < Exception
    end

    class TimeoutError < Transport::Error
    end
  end
end
