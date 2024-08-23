## Rclone Setup and Config

`sudo -v ; curl https://rclone.org/install.sh | sudo bash`

```
rclone config

n

name> docker_to_onedrive

Storage> 33

region> 1 Microsoft Cloud Global

Edit advanced config?
y) Yes
n) No (default)
y/n> n

Use web browser to automatically authenticate rclone with remote?
 * Say Y if the machine running rclone has a web browser you can use
 * Say N if running rclone on a (remote) machine without web browser access
If not sure try Y. If Y failed, try N.

y) Yes (default)
n) No
y/n> n

Option config_token.
For this to work, you will need rclone available on a machine that has
a web browser available.
For more help and alternate methods see: https://rclone.org/remote_setup/
Execute the following on the machine with the web browser (same rclone
version recommended):
        rclone authorize "onedrive"
Then paste the result.
Enter a value.
config_token> { xxx }

Option config_type.
Type of connection
Choose a number from below, or type in an existing value of type string.
Press Enter for the default (onedrive).
 1 / OneDrive Personal or Business
config_type> 1

Option config_driveid.
Select drive you want to use
Choose a number from below, or type in your own value of type string.
Press Enter for the default (b!TkGKJU0VKEG-NbexVFnj-iFo7o78Q5NMmA3ZQmA1zGh4Eu8SeRVNQ4AUQbcy8iG6).
 1 / Dokumente (business)
   \ (b!TkGKJU0VKEG-NbexVFnj-iFo7o78Q5NMmA3ZQmA1zGh4Eu8SeRVNQ4AUQbcy8iG6)
config_driveid> 1

Drive OK?

Found drive "root" of type "business"
URL: https://yellowfox-my.sharepoint.com/personal/lucas_graf_yellowfox_onmicrosoft_com/Documents

y) Yes (default)
n) No
y/n> y
```

## Backup Bash Script
#! TODO: Use check to only stop containers if changes detected

<br/>
<br/>

[Jump to parent file](README.md)