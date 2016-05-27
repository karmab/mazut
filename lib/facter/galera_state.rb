Facter.add(:galera_state, :timeout => 10) do
  setcode do
    if not File.exist?('/etc/my.cnf') or not File.exists?('/usr/lib64/galera/libgalera_smm.so') or not File.exists?('/usr/sbin/pcs')
      'waiting'
    elsif Facter::Util::Resolution.exec('/usr/sbin/pcs status | /usr/bin/grep Masters:') =~ /Masters/
      'running'
    else
      'ready'
    end
  end
end
