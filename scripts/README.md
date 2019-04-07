# Magento Unison
Bash scripts for syncing Magento projects between local and development servers.

## Sync Project
This script syncs the Magento project using Unison. 
Add the following to your crontab `crontab -e`:
```
* * * * * ~/Documents/Projects/magento-docker/scripts/sync_project 
~ davidtay 10.0.2.2 /Users/davidtay Documents/Projects/projectname projectname /usr/local/bin/unison
```

## Fix Owner Permissions
This script fixes permissions of files synced between the roots. It needs to run as root `sudo crontab -e`:
```
* * * * * /home/davidtay/Documents/Projects/magento-docker/scripts/fix_owner_perms 
/home/davidtay/Documents/Projects/projectname 2 www-data:www-data 664 775
```