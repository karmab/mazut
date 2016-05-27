module Puppet::Parser::Functions
  newfunction(:createacl, :type => :rvalue, :doc => <<-EOS
join acls into an array adding some formating
EOS
  ) do |acls|

    retval = []
    acls = acls[0]

    acls.each do |acl|
      acl.keys.each do |key|
        name = key
        host = acl[key]['host']
        r = "#{name} hdr(host) -i #{host}"
        retval << r
     end
    end

    return retval
  end
end
