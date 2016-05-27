Facter.add("isolcpus") do
  setcode do
    processors = Array.new
    coreids    = Array.new
    isolcpus   = Array.new
    File.readlines("/proc/cpuinfo").each do |line|
         coreid     = $1 if line =~ /core id.*: (.*)/
         processor  = $1 if line =~ /processor.*: (.*)/
         if not coreid.nil?
           coreids << coreid
         end
         if not processor.nil?
           processors << processor
         end
    end
    processors.each_with_index do |processor,index|
      if coreids[index] != '0'
        isolcpus << processor
      end
    end
    isolcpus.join(',')
  end
end
