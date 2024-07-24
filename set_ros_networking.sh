# set_ros_ip.sh
#!/bin/bash
export ROS_MASTER_URI="http://169.254.21.103:11311"
# Choose the IP address that starts with 169
export ROS_IP=$(hostname -I | awk '{for(i=1;i<=NF;i++) if ($i ~ /^169\./) print $i}')
exec "$@"