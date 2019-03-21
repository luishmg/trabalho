# Ruby script to configure the workstation
require 'io/console'

# Verify input string
def verifyInput(string,message,regex)
  if string.nil? || string == ""
    puts message
    abort
  end
end
# Verify boolean and diplay error and maybe sucess messages
def error?(tof, error, sucess = "")
  if tof then
    puts sucess
    `echo "#{Time.now.strftime("%d/%m/%Y %H:%M")} #{sucess} >> preparingApache.log"`
  else
    puts error
    `echo "#{Time.now.strftime("%d/%m/%Y %H:%M")} #{error} >> preparingApache.log"`
    abort
  end
end
# Conver shell exit to true or false
def shexit(shell)
  return true if shell == 0
  return false if shell == 1
end
# Install Chefdk based on distro
def installChefdk(distro,version,exit)
  if  exit == 1 then
    puts version
    `wget https://packages.chef.io/files/stable/chefdk/3.8.14/#{distro}/#{version}/chefdk_3.8.14-1_amd64.deb -O ~/chefdk.deb`
    `sudo dpkg -i ~/chefdk.deb`
    return true
  else
    return true
  end
end

serverDistro = `cat /etc/issue`
case serverDistro
when /.*ubuntu.*/i
  distroVersion = `tr -d '\\n' < /etc/issue | sed -r 's/[^0-9]*([0-9]+\\.?[0-9]+)[. ].*/\\1/g'`
  `dpkg -l chefdk`
  installed = installChefdk("ubuntu", distroVersion, $?.exitstatus)
when /.*centos.*/i
  distroVersion = `sed -r 's/[^0-9]*([0-9]+)\\..*/\\1/g' /etc/issue | tr '\\n' ''`
  `rpm -a | grep -i chefdk`
  installed = installChefdk("centos", distroVersion, $?.exitstatus)
end
error?(installed,"Error ocurred while installing chefdk")
`chef shell-init bash`
`chef generate repo ~/chef-repo`

# Get chef server info
puts "Enter chef-server user: "
serverUser = gets.chomp
verifyInput(serverUser,"Invalid entry null or invalid input",nil)
puts "Enter chef-server ip: "
serverIP = gets.chomp
verifyInput(serverUser,"Invalid entry null or invalid input",nil)

`ip a | grep #{serverIP}`
if $?.exitstatus == 0 then
  `cp /opt/chefkeys/lgomes.pem ~/.chef/lgomes.pem`
else
  `scp #{serverUser}@#{serverIP}:/opt/chefkeys/lgomes.pem ~/.chef/lgomes.pem` 
end
`echo 'cookbook_path ["~/chef-repo/cookbooks"]' > ~/.chef/knife.rb`
`cp -r cookbooks/* ~/chef-repo/cookbooks/`
`cp -r data_bags ~/chef-repo/`
