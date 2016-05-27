module Puppet::Parser::Functions
  newfunction(:createaclrules, :type => :rvalue, :doc => <<-EOS
join acls into an array adding some formating
EOS
  ) do |acls|

    retval = []
    acls    = acls[0]

    acls.each do |acl|
      acl.keys.each do |key|
        name = key
        r = "#{name}_backend if #{name}"
        retval << r
      end
    end
    return retval
  end
end
