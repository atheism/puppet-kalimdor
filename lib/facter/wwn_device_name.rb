
require 'facter'
require 'timeout'

timeout = 5

begin
    Timeout::timeout(timeout) {
        
        if Facter.value(:is_virtual) == true then
            blkid_all = Facter::Util::Resolution.exec("[ -d /dev/disk/by-id/ ] && ls -l  /dev/disk/by-id/ | awk '{print $9,$11}' | grep virtio")
            #puts blkid
            wwn_dev_name_dict = Hash.new
            blkid_all and blkid_all.each_line do |line|
               if line =~ /^(virtio-.+) \.\.\/\.\.\/([a-zA-Z0-9]+)/
                   disk_wwn = $1
                   tmp = $2
                   disk_dev = "/dev/#{tmp}"
                   wwn_dev_name_dict[disk_wwn] = disk_dev
               end
            end
        else
            blkid_all = Facter::Util::Resolution.exec("[ -d /dev/disk/by-id/ ] && ls -l  /dev/disk/by-id/ | awk '{print $9,$11}' | grep wwn")
            #puts blkid
            wwn_dev_name_dict = Hash.new
            blkid_all and blkid_all.each_line do |line|
               if line =~ /^(wwn-.+) \.\.\/\.\.\/([a-zA-Z0-9]+)/
                   disk_wwn = $1
                   tmp = $2
                   disk_dev = "/dev/#{tmp}"
                   wwn_dev_name_dict[disk_wwn] = disk_dev
               end
            end
        end
        
        #puts wwn_dev_name_dict
        Facter.add("wwn_dev_name_hash") do
             setcode do
               wwn_dev_name_dict
             end
        end
    }

rescue Timeout::Error
    Facter.warnonce('Can not get wwn-devname mapping fact')
end
