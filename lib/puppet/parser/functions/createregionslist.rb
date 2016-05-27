module Puppet::Parser::Functions
  newfunction(:createregionslist, :type => :rvalue, :doc => <<-EOS
join acls into an array adding some formating
EOS
  ) do |regions|

    retval   = []
    regions  = regions[0]
    version  = 'v2.0'
    protocol = 'http'
    port     = '5000'

    regions.each do |region|
        name = region[0]
        if region[1].keys.include? 'url'
          url = region[1]['url']
        else
          if region[1].keys.include? 'host'
            host = region[1]['host']
          end
          if region[1].keys.include? 'version'
            version = region[1]['version']
          end
          if region[1].keys.include? 'protocol'
            protocol = region[1]['protocol']
          end
          if region[1].keys.include? 'port'
            port = region[1]['port']
          end
          url  = "#{protocol}:#{host}:#{port}//#{version}"
        end
        r = [url,name]
        retval << r
     end
    return retval
  end
end
