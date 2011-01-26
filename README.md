# Pachube Boris Bike Data

This is a very simple little script for pushing liveish data from Adrian Short's
Boris Bike Data API (http://borisbike.heroku.com) into Pachube.

## Prerequisites

* Ruby 1.8.7+
* Bundler 1.0.2+
* A Pachube account (http://www.pachube.com)

## Installation

The script uses bundler (http://gembundler.com) to manage it's very limited
dependencies so the gems can be installed by running:

    $ bundle install

## Create a Pachube feed where data will be sent.

Currently this script doesn't try to create the Pachube environment for you, so
you'll have to do this manually beforehand. Make a note of the environment id,
as we'll need this when setting up the config file.

## Create a new API key for the application (optional)

The following script can perfectly well be run with your master API key, but
rather than using that key, it's probably better to create a limited API key.
These limited API keys can be created which only have permissions to use
specific HTTP methods, or that are limited to specific IP addresses etc. 

For this script we need a key with PUT access rights, which can be IP limited
if necessary, and the easiest way of creating this is by logging into your
Pachube account and accessing your Settings page where you should be able to
create the new API key.

## Create config file

Copy the template file in config.yml.template to config.yml and into it insert
the values created above. 

The other important value to add is the id of the station you want to send
updates for.  The stations with their ids are listed on the Boris Bike api site
(http://borisbike.heroku.com), and the value you need here is the integer id.

Ultimately your config.yml file should look something like this:

  :station_id: 32
  :feed_id: 1928
  :api_key: 2p-F63EXRgRNovHPV9IoBIWtqlalof-EBy9GdTioveE
  :api_url: http://api.pachube.com/v2/feeds

## Running the script

Once the config file has been properly configured, then you should be able to run
it like this:

    $ ./borisbikes.rb

If this all went right it won't produce any output, but will exit with a success code.
Any problems should produce some error output, and an error exit code.

This single run will only push a single data point into Pachube, so to send live data
in there, you'll need to call the script periodically, so probably the easiest way
of implementing that is to use cron.
