class Redis
  module Protocol
    alias Value = NonBinarySafeString | BinarySafeString | Error | Integer | Null | RedisArray
  end
end
