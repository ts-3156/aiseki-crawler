#!/usr/bin/ruby

require 'anemone'
require 'fileutils'
require 'optparse'

module Crawl
  class Place
    NAMES = %w(
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

    attr_reader :name, :men, :lady

    def initialize(name, men, lady)
      @name, @men, @lady = name, men, lady
    end

    def to_s
      "#{name} #{men} #{lady}"
    end
  end
  
  class Cache
    class << self
      def time2key(time)
        time.is_a?(String) ? time : time.strftime("%Y%m%d%H%M") # yyyymmddhhmm
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

  class Scraper
    URL = 'http://oriental-lounge.com/'

    class << self
      def scrape(time)
        html = Cache.fetch(time) { fetch(URL).to_html }
        doc = Nokogiri::HTML(html)
        Place::NAMES.map do |name|
          str = parse(doc, "//a[@id='box_#{name}']")
          men, lady = extract(str)
          Place.new(name, men, lady)
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
    end
  end
end

if $0 == __FILE__
  places = Crawl::Scraper.scrape(Time.now)

  print Time.now.to_s + ' '
  puts places.map(&:to_s).join(', ')
end



