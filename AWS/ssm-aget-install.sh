#################################################################
#
#		Installation of SSM Agent 
#
#################################################################
#/bin/bash!
package="amazon-ssm-agent"
if [ -n "$(command -v lsb_release)" ]; then
	distroname=$(lsb_release -s -d)
elif [ -f "/etc/os-release" ]; then
	distroname=$(grep PRETTY_NAME /etc/os-release | sed 's/PRETTY_NAME=//g' | tr -d '="')
elif [ -f "/etc/debian_version" ]; then
	distroname="Debian $(cat /etc/debian_version)"
elif [ -f "/etc/redhat-release" ]; then
	distroname=$(cat /etc/redhat-release)
else
	distroname="$(uname -s) $(uname -r)"
fi
OS=`echo $distroname | cut -d' ' -f1`
REL=`echo $distroname | cut -d' ' -f2 | cut -d'.' -f1`
AREL=`echo $distroname | cut -d' ' -f4 | cut -d'.' -f1`
if [ "$OS" == "Ubuntu" ]; then
	{
	dpkg -s $package &> /dev/null
	if [ $? -eq 0 ]; then
		{
    		echo "Package $package is installed!"
		}
	else
		{
		wget -q -t 1 --timeout=10 https://s3.amazonaws.com/ec2-downloads-windows/SSMAgent/latest/debian_amd64/amazon-ssm-agent.deb -O /tmp/ssm-agent.deb; sudo dpkg -i /tmp/ssm-agent.deb;
		rm -f /tmp/ssm-agent.deb
		if [ "$REL" -le "14" ]; then
			{
			#Ubuntu 14 or less
			sudo restart $package;
			}
		elif [ "$REL" -gt "14" ]; then
                     {
                        #Ubuntu 14 or latest
			sudo systemctl restart $package;sudo systemctl enable $package;sudo snap restart $package;
                        }
		fi
		}
	rm -f /tmp/ssm-agent.deb
	fi
	}
elif [ "$OS" == "Amazon" ]; then
	{
	isinstalled=$(rpm -q $package)
	if [ ! "$isinstalled" == "package $i is not installed" ];then
		{
		#rpm -q "$package" > /dev/null 2>&1 &&  echo "$package is already installed" || sudo yum install -y https://s3.amazonaws.com/ec2-downloads-windows/SSMAgent/latest/linux_amd64/amazon-ssm-agent.rpm;
		yum makecache fast
		sudo yum install -y https://s3.amazonaws.com/ec2-downloads-windows/SSMAgent/latest/linux_amd64/amazon-ssm-agent.rpm;
		
		if [ "$AREL" -ge "2018" ]; then
			{
			#Amazone Linux 2018
			sudo systemctl restart $package;sudo systemctl enable $package;
			}
		elif [ "$AREL" -le "2017" ]; then
                        {
                        #Amazone Linux 2014
                        sudo restart $package;
                        }
		fi
		}
	else 
		{
			echo "Package $package is already installed";
		}
	fi
	}
elif [ "$OS" == "CentOS" ]; then
	{
		sudo yum install -y https://s3.amazonaws.com/ec2-downloads-windows/SSMAgent/latest/linux_amd64/amazon-ssm-agent.rpm;
		sudo systemctl enable $package;sudo systemctl restart $package;sudo restart $package;
	}
else
	{
		echo "I'm sorry.. I had a hard time understanding the OS Platform" >&2;
		exit 1;
	}
fi
# END
