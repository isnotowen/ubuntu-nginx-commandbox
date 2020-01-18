#install commandbox
echo "Installing Java"
apt-get install default-jre -y
apt-get install openjdk-11-jre-headless -y
apt-get install openjdk-8-jre-headless -y
apt-get install openjdk-9-jre-headless -y

apt-get install default-jre -y
java -version

echo "Installing CommandBox"

curl -fsSl https://downloads.ortussolutions.com/debs/gpg | apt-key add -
echo "deb https://downloads.ortussolutions.com/debs/noarch /" | tee -a /etc/apt/sources.list.d/commandbox.list
apt-get update && apt-get install commandbox -y

echo "Installing CommandBox CFCONFIG"
box install commandbox-cfconfig

echo "Installing CommandBox DOTENV"
box install commandbox-dotenv

echo "Copying CommandBox Startup Script"
cp etc/init.d/commandbox-startup.sh /etc/init.d/commandbox-startup.sh
chmod +x /etc/init.d/commandbox-startup.sh
echo "Adding CommandBox Startup Script to boot sequence"
update-rc.d /etc/init.d/commandbox-startup.sh defaults