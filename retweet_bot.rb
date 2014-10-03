#!/usr/bin/env ruby

#require 'pry-byebug'
require 'logger'
require 'yaml'
require 'twitter'

conf = YAML.load_file("#{File.dirname(__FILE__)}/config/#{ARGV[0]}.yml")
logger = Logger.new("#{File.dirname(__FILE__)}/log/#{ARGV[0]}.log", conf['logger']['shift_age'])

logger.info('Starting process')

client = Twitter::REST::Client.new do |c|
  c.consumer_key        = conf['twitter']['consumer_key']
  c.consumer_secret     = conf['twitter']['consumer_secret']
  c.access_token        = conf['twitter']['access_token']
  c.access_token_secret = conf['twitter']['access_token_secret']
end

query = conf['search_queries'].sample
ng_words = conf['ng_words']
ng_clients = conf['ng_clients']
ng_users = conf['ng_users']
succeed = false
errors = []

client.search(query).take(100)
  .select { |t| t.full_text.index(query) }
  .reject { |t| ng_words.any? { |w| t.full_text.index(w) } }
  .reject { |t| ng_clients.any? { |c| t.source.index(c) } }
  .reject { |t| ng_users.any? { |u| t.user.screen_name == u } }
  .sample(3) # retry 3 times
  .each do |t|
    begin
      logger.info("Retweeting #{t.url}")
      client.retweet(t)
      logger.info("Retweeted: #{t.url}")
    rescue Twitter::Error => e
      error = "Failed retweeting: #{t.url} #{e.to_s}"
      errors << error
      logger.info(error)
    else
      succeed = true
      break
    end
  end

# if all retweet attempts failed, put errors to STDERR
unless succeed
  STDERR.puts 'All attempts have failed!'
  errors.each { |e| STDERR.puts e }
end
