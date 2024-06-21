# set_ros_ip.sh
#!/bin/bash
export ROS_MASTER_URI="http://169.254.21.103:11311"
export ROS_IP=$(hostname -I | awk '{print $1}')
exec "$@"