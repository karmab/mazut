Facter.add(:cluster_online, :timeout => 10) do
  setcode do
    if not File.exists?('/usr/sbin/pcs')
      0
    else
      Facter::Util::Resolution.exec("/usr/sbin/pcs status | /usr/bin/grep Online | /usr/bin/grep -v ']'  | /usr/bin/wc -l")
    end
  end
end
