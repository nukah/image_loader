#!/usr/bin/env ruby
require 'optparse'
require 'bundler'
require 'logger'
require_relative 'lib/image_loader'

Bundler.require

OptionParser.new do |parser|
  parser.banner = 'Usage: loader.rb http://page.url'
end.parse!

url = ARGV.pop
logger = Logger.new(STDOUT)

begin
  ImageLoader.new(url, logger).save
rescue Exception => e
  logger.error(e.message)
end
