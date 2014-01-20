#!/usr/bin/env ruby

require 'YAML'
require 'Twitter'

conf = YAML.load_file("config/#{ARGV[0]}.yml")

client = Twitter::REST::Client.new do |c|
  c.consumer_key        = conf['twitter']['consumer_key']
  c.consumer_secret     = conf['twitter']['consumer_secret']
  c.access_token        = conf['twitter']['access_token']
  c.access_token_secret = conf['twitter']['access_token_secret']
end

query = conf['search_queries'].sample
ng_words = conf['ng_words']
ng_clients = conf['ng_clients']

tweet = client.search(query, {count: 100})
  .select{ |t| t.full_text.index(query) }
  .reject{ |t| ng_words.any?{ |w| t.full_text.index(w) } }
  .reject{ |t| ng_clients.any? { |c| t.source.index(c) } }
  .sample

client.retweet(tweet)
