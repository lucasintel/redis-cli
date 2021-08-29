class Redis
  module Protocol
    record RedisArray, value : Array(NonBinarySafeString | BinarySafeString | Error | Integer | Null | RedisArray)
  end
end
