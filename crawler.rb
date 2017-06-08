#!/usr/bin/ruby

require 'anemone'

url = 'http://oriental-lounge.com/'
places = %w(
  sapporo
  sendai
  shinjuku
  shibuya
  machida
  nagoya
  kyoto
  shinsaibashi
  kobe
  hiroshima
  fukuoka
  kumamoto
  kagoshima
  okinawa
)

class Cache
  class << self
    def time2key(time)
      time.strftime("%Y%m%d%H%M") # yyyymmddhhmm
    end

    def dir
      "#{Dir.pwd}/.cache"
    end

    def file(time)
      "#{dir}/#{time2key(time)}"
    end

    def exists?(time)
      FileTest.exist?(file(time))
    end

    def read(time)
      File.read(file(time))
    end

    def write(time, html)
      FileUtils.mkdir_p(dir) unless FileTest.exist?(dir)
      File.write(file(time), html)
    end

    def fetch(time)
      if block_given?
        if exists?(time)
          read(time)
        else
          result = yield
          write(time, result)
          result
        end
      else
        read(time)
      end
    end
  end
end

def fetch(url)
  Anemone.crawl(url, depth_limit: 0) do |anemone|
    anemone.on_every_page do |page|
      return page.doc
    end
  end
end

def parse(doc, xpath)
  doc.xpath(xpath).each do |tag|
		return tag.text
  end
end

def extract(str)
  str.strip.match(/(\d+)[^\d]+(\d+)/).to_a.slice(1, 2)
end

html = Cache.fetch(Time.now) { fetch(url).to_html }
doc = Nokogiri::HTML(html)
counts = places.map { |p| parse(doc, "//a[@id='box_#{p}']") }.map { |s| extract(s) }

print Time.now.to_s + ' '
puts places.map.with_index { |p, i| "#{p} #{counts[i][0]} #{counts[i][1]}" }.join(', ')




