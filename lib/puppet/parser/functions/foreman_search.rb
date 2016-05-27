# Query Foreman
#
# The foreman_search() parser takes a scoped search string argument and optionally a  with parameters to execute the query.
#
# To use search(), first define the following hiera values:
#
# 'foreman_url'  => actual foreman server address
# 'foreman_user' => username of an account with API access
# 'foreman_pass" => password of an account with API access
# 'item' may be: environments, fact_values, hosts, hostgroups, puppetclasses, smart_proxies, subnets
# 'search' is your actual search query.
#
# Then, use the following to to a search:
# $search = "facts.state =ready and hostgroup=XXX"
# $hosts  = search($search)
#
# you can optionally pass a second argument to within the following to indicate the objects to look at ( otherwise defaults to hosts )
# environments, fact_values, hosts, hostgroups, puppetclasses, smart_proxies, subnets
#
# Note: If you're using this in a template, you may be receiving an array of
# hashes. So you might need to use two loops to get the values you need.
#
# Mc Fly!

require "net/http"
require "net/https"
require "uri"
require "timeout"

module Puppet::Parser::Functions
  newfunction(:foreman_search, :type => :rvalue) do |args|
    search       = args[0]
    item         = 'hosts'
    item         = args[1] if args.length == 2
    per_page     = '20'
    foreman_url  = function_hiera(['foreman_url','https://localhost']) # defaults: all-in-one
    foreman_user = function_hiera(['foreman_user','admin'])             # has foreman/puppet
    foreman_pass = function_hiera(['foreman_pass','changeme'])          # on the same box

    # extend this as required
    searchable_items = %w{ environments fact_values hosts hostgroups puppetclasses smart_proxies subnets }
    raise Puppet::ParseError, "Foreman: Invalid item to search on: #{item}, must be one of #{searchable_items.join(", ")}." unless searchable_items.include?(item)

    begin
      path = URI.escape("/api/#{item}?search=#{search}&per_page=#{per_page}")
      uri = URI.parse(foreman_url)

      req = Net::HTTP::Get.new(path)
      req.basic_auth(foreman_user, foreman_pass)
      req['Content-Type'] = 'application/json'
      req['Accept'] = 'application/json'

      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true if uri.scheme == 'https'
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE if http.use_ssl?
      Timeout::timeout(5) { PSON.parse http.request(req).body }
    rescue Exception => e
      raise Puppet::ParseError, "Failed to contact Foreman at #{foreman_url}: #{e}"
    end
  end
end
