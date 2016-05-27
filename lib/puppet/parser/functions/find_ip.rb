require 'facter/util/ip' 
module Puppet::Parser::Functions
    newfunction(:find_ip, :type => :rvalue, :doc => <<-EOS
This returns the ip associated with the given network or nic. 
                EOS
) do |arguments|
    Puppet::Parser::Functions.autoloader.loadall
    raise(Puppet::ParseError, "find_ip(): Wrong number of arguments " +
      "given (#{arguments.size} for 3)") if arguments.size < 3

    the_network= arguments[0] ||= ''
    the_nic = arguments[1] ||= ''
    the_ip = arguments[2] ||= ''

    if (the_network != '')
      function_get_ip_from_network([the_network])
    elsif (the_nic != '')
      function_get_ip_from_nic([the_nic])
    else
      the_ip
    end
  end
end
