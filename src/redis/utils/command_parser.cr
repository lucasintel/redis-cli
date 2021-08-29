class Redis
  class CommandParser
    BACKSLASH_CHAR = '\\'
    QUOTE_CHAR     = '"'
    SEPARATOR_CHAR = ' '
    STOP           = '\0'

    private delegate next_char, current_char, pos, to: @reader

    def self.call(command : String)
      new(command).call
    end

    def initialize(command : String)
      @reader = Char::Reader.new(command)
      @buffer = IO::Memory.new
    end

    def call : Redis::Protocol::Command
      command = [] of String

      while @reader.has_next?
        command << consume
      end

      command
    end

    private def consume
      consume_single
      read_buffer
    end

    private def consume_single
      case current_char
      when SEPARATOR_CHAR
        next_char
        consume_single
      when QUOTE_CHAR
        consume_quoted_string
      else
        consume_unquoted_string
      end
    end

    private def consume_quoted_string
      loop do
        case next_char
        when BACKSLASH_CHAR
          case next_char
          when QUOTE_CHAR
            append_to_buffer current_char
          else
            append_to_buffer BACKSLASH_CHAR
            append_to_buffer current_char
          end
        when QUOTE_CHAR
          case next_char
          when SEPARATOR_CHAR, STOP
            break
          else
            raise "expected separator, got: #{current_char}"
          end
        else
          append_to_buffer current_char
        end
      end
    end

    private def consume_unquoted_string
      loop do
        case current_char
        when QUOTE_CHAR
          raise "unexpected quote on position: #{pos}"
        when SEPARATOR_CHAR, STOP
          break
        else
          append_to_buffer current_char
          next_char
        end
      end
    end

    private def append_to_buffer(char : Char)
      @buffer << char
    end

    private def read_buffer
      contents = @buffer.to_s
      @buffer.clear
      contents
    end
  end
end
