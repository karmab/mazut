Facter.add(:cluster_state, :timeout => 10) do
  setcode do
    hostname = Facter.value(:hostname)
    if not File.exists?('/usr/sbin/pcs')
      'waiting'
    elsif Facter::Util::Resolution.exec("/usr/sbin/pcs status | /usr/bin/grep Online | /usr/bin/grep #{hostname}") != ''
      'online'
    else
      'offline'
    end
  end
end
