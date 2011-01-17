#!/usr/bin/env ruby
require 'rubygems'
require 'json'
require 'sequel'
require 'fileutils'

DB = Sequel.sqlite("data/stations.db")

unless DB.tables.include?(:stations)
  DB.create_table :stations do
    primary_key :id
    column :station_id, :integer, :null => false, :index => true
    column :feed_id, :integer
  end
end

stations_dataset = DB[:stations]

def lockfile
  "#{File.expand_path(File.dirname(__FILE__))}/bikedata.lock"
end

def get_data
  data = JSON.parse(IO.read("data/stations.json"))
end

if File.exist?(lockfile)
  puts "Lockfile already exists; last run must not have completed cleanly"
  exit 1
end

begin
  FileUtils.touch(lockfile)

  stations = fetch_data
  
  stations.each do |station|
    puts "Looking at station: #{station.inspect}"
    station_entry = stations_dataset.filter(:station_id => station["id"]).first
    if station_entry.nil?
      puts "Creating a new environment"
      # create a pachube environment for this entry
      # insert a local record linking the station id with a remote feed id
    else
      puts "Updating an existing environment"
      # update the feed indicated by our record
    end
  end
rescue Exception => e
  puts "Error updating pachube: #{e.inspect}"
ensure
  FileUtils.rm_f(lockfile)
end

# if lockfile exists exit with an error
# else create the lockfile
# for each fetched record
#   select that record in the db (using station id)
#   if feed_id is null
#     create a pachube environment using the station data
#     insert a record into our local database linking the station id with the feed id
#   else
#     update a pachube environment using the station data
#   end
# end
