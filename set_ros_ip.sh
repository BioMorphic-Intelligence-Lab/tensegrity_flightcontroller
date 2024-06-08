# set_ros_ip.sh
#!/bin/bash
export ROS_IP=$(hostname -I | awk '{print $1}')
exec "$@"