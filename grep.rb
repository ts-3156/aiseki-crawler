#!/usr/bin/ruby

require 'time'
require 'json'

if $0 == __FILE__
  name, gender = ARGV[1], ARGV[2]

  puts '['

  File.read('log/cron.log').split("\n").each do |line|
    m = line.match(/(?<time>\d+-\d+-\d+ \d+:\d+:\d+).+#{name} (?<man>\d+) (?<woman>\d+)/)
    next unless m
    puts [Time.parse(m[:time]).to_i * 1000, m[gender.to_sym].to_i].to_json
  end

  puts ']'
end



