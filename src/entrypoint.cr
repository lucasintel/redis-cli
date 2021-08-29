require "./redis"
require "./applications/cli"

CLI.new(ARGV).run
