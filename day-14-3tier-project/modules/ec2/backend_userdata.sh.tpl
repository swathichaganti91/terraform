#!/bin/bash
yum update -y
yum install -y git mysql

# install Node.js & PM2
dnf install -y nodejs
npm install -g pm2

# clone backend project
cd /root
git clone https://github.com/your/repo.git
cd repo/backend

# create .env file
cat > .env <<EOL
DB_HOST=${db_endpoint}
DB_USER=${db_user}
DB_PASS=${db_pass}
DB_NAME=${db_name}
EOL

npm install
pm2 start index.js --name node-app
