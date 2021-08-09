# Presumes BasecampTest.dmg that mounts to /Volumes/BCamp_test
# and existene of gmapsupp.img
#



if [[ $(mount | awk '$3 == "/Volumes/BCamp_test" {print $3}') != "" ]]; then
 echo /Volumes/BCamp_test is mounted
else
 hdiutil attach ./BasecampTest.dmg  
fi

cp gmapsupp.img /Volumes/BCamp_test/Garmin/

#umount and mount cycle 
hdiutil detach -force `mount | awk '$3 == "/Volumes/BCamp_test" {print $3}'`
sleep 2
hdiutil attach ./BasecampTest.dmg  


