class Redis
  module ResultFormatter
    extend self

    def format(object : Redis::Protocol::NonBinarySafeString | Redis::Protocol::Error) : String
      object.value
    end

    def format(object : Redis::Protocol::BinarySafeString) : String
      object.value.dump
    end

    def format(object : Redis::Protocol::Integer) : String
      "(integer) #{object.value}"
    end

    def format(object : Redis::Protocol::RedisArray) : String
      String.build do |io|
        object.value.each_with_index(offset: 1) do |item, index|
          io << "#{index}) #{format(item)}"
          io << '\n' unless index == object.value.size
        end
      end
    end

    def format(object : Redis::Protocol::Null) : String
      "(nil)"
    end
  end
end
