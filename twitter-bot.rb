#!/usr/bin/env ruby

#require 'byebug'
require 'Logger'
require 'YAML'
require 'Twitter'

conf = YAML.load_file("config/#{ARGV[0]}.yml")
logger = Logger.new("log/#{ARGV[0]}.log", conf['logger']['shift_age'])

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

client.search(query, {count: 100})
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
      logger.info("Failed: #{t.url} #{e}")
    else
      succeed = true
      break
    end
  end

# if all retweet attempts failed, send an alert mail
unless succeed
  # TODO
end
