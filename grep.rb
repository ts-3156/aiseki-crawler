#!/usr/bin/ruby

require 'optparse'

if $0 == __FILE__
  name = ARGV.getopts('', 'name:')['name']
  puts name
  File.read('log/cron.log').split("\n").each do |line|
    puts line.match(/(\d+-\d+-\d+ \d+:\d+:\d+).+#{name} (\d+) (\d+)/).to_a.slice(1, 3).join(', ')
  end
end



