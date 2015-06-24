#!/bin/bash

test -f /etc/bootstrapped && exit

echo '# Add resolv.conf options.'
echo "options single-request-reopen" >> /etc/resolv.conf

echo '# Update default yum packages.'
yum update -y

echo '# Installing Chef-Solo.'
curl -L http://www.opscode.com/chef/install.sh | bash

echo '# Installing packages.'
yum install -y openssl-devel mlocate

date > /etc/bootstrapped

