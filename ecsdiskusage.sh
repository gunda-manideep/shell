#!/bin/bash
sudo apt-get update -y
sudo apt-get install python -y
sudo apt-get install awscli -y
sudo aws configure set region xx-xxxx-x && \
mkdir /tmp/diskspace && \
cd /tmp/diskspace && \
sudo cat << 'EOF' >/tmp/diskspace/diskusagealert.sh
#!/bin/sh
df -H | grep -vE '^Filesystem|tmpfs|cdrom' | awk '{ print $5 " " $1 }' | while read output;
do
  echo $output
  usep=$(echo $output | awk '{ print $1}' | cut -d'%' -f1  )
  account="$(aws sts get-caller-identity --query Account --output text)"
  instanceid="$(wget -q -O - http://169.254.169.254/latest/meta-data/instance-id)"
  az=`curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone`
  region="`echo \"$az\" | sed 's/[a-z]$//'`"
  partition=$(echo $output | awk '{ print $2 }' )
  if [ $usep -ge 90 ]; then
    aws sns publish \
    --topic-arn "xxxxx:xxxxx:xxxxx;xxxxxxx" \
    --message "Running out of space \"$partition ($usep%)\" on $(hostname) in ($region) instanceidis ($instanceid) accountidis ($account) as on $(date)"
  fi
done

EOF
sudo cp diskusagealert.sh /etc/cron.daily/ && \
sudo chmod +x /etc/cron.daily/diskusagealert.sh && \
(crontab -l ; echo "10 0 * * * /etc/cron.daily/diskusagealert.sh")| crontab -
