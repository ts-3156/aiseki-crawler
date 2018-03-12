#!/usr/bin/ruby

require 'time'
require 'json'

if $0 == __FILE__
  #
  # ruby convert.rb log/cron.log shinjuku man >docs/shinjuku_man.json
  #

  log = ARGV[0]
  name, gender = ARGV[1..2]
  regexp = /(?<time>\d+-\d+-\d+ \d+:\d+:\d+ \+0000).+#{name} (?<man>\d+) (?<woman>\d+)/

  json = []

  File.read(log).each_line do |line|
    next unless (m = line.match regexp)
    json << [Time.parse(m[:time]).to_i * 1000, m[gender.to_sym].to_i]
  end

  puts json.to_json
end



