#!/bin/bash
cat > index.html <<EOF
echo ${server_text}
echo "DB address: ${db_address}"
echo "DB password: ${db_port}"
EOF
nohup busybox httpd -f -p ${server_port} &