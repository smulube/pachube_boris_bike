#!/usr/bin/env ruby

require 'rubygems'
require 'bundler/setup'

require 'yajl/http_stream'
require 'yaml'
require 'rest_client'

# Load the config options.
begin
  CONFIG = YAML.load_file(File.join(File.dirname(__FILE__), "config.yml"))
rescue
  puts "Unable to load config file. This should be a file called config.yml in the same directory as this file."
  exit 1
end

# Id of the station we want to send updates for.
STATION_ID = CONFIG[:station_id]

# Pachube feed id
FEED_ID = CONFIG[:feed_id]

# Insert your api key here
API_KEY = CONFIG[:api_key]

# The data provided by adrian short
SOURCE_URL = URI.parse("http://borisapi.heroku.com/stations.json")

# The api url
API_URL = CONFIG[:api_url]

# Get all the station data
begin
  station_data = Yajl::HttpStream.get(SOURCE_URL)
rescue Exception => e
  puts "Unable to fetch remote data: #{e.inspect}"
  exit 1
end

# Get the data for the station we are interested
station = station_data.find { |s| s["id"].to_i == STATION_ID }

# Exit if we can't find the station we want
if station.nil?
  puts "Unable to find station id: #{STATION_ID}"
  exit 1
end

# Construct the json data we are going to send (ugly)
feed_data = { :title => "Boris Bike Station: #{station["id"]} - #{station["name"]}",
              :description => "Liveish data on the current status of this Barclays Cycle hire station. Data sourced from the TFL's bike hire map, via Adrian Short's Boris Bike API.",
              :website => "http://borisapi.heroku.com/",
              :version => "1.0.0",
              :tags => ["boris bikes","london","barclays cycle hire","opendata"],
              :location => { 
                :disposition => "fixed",
                :name => station["name"],
                :lat => station["lat"],
                :lon => station["long"],
                :exposure => "outdoor",
                :domain => "physical"
              },
              :datastreams => [
                { 
                  :id => "0",
                  :current_value => station["nb_bikes"],
                  :tags => ["number of bikes", "counter"]
                },
                {
                  :id => "1",
                  :current_value => station["nb_empty_docks"],
                  :tags => ["number of empty docks", "counter"]
                },
                {
                  :id => "2",
                  :current_value => station["locked"].to_s,
                  :tags => ["locked", "boolean"]
                },
                {
                  :id => "3",
                  :current_value => station["temporary"].to_s,
                  :tags => ["temporary", "boolean"]
                },
                {
                  :id => "4",
                  :current_value => station["installed"].to_s,
                  :tags => ["installed", "boolean"]
                }
              ]
            }

options = { "X-PachubeApiKey" => API_KEY, "User-Agent" => "Boris Bike Client",
  "Accept" => "application/json" }

begin
  response = RestClient.put("#{API_URL}/#{FEED_ID}.json", Yajl::Encoder.encode(feed_data), options)
  
  if response.code != 200
    raise "Error sending data to Pachube: #{response.code}"
  end
rescue Exception => e
  puts "Error updating resource: #{e.inspect}"
  exit 1
end
