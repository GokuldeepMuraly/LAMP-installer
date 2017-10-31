#!/bin/bash
#Script by Gokuldeep
package_list="httpd  mysql-server  php-* " 
service_list="httpd mysqld"
for package in ${package_list}
do 
        echo -e "INSTALLING THE PACKAGE ${package} "
	yum install -y ${package} 
done


for service in ${service_list}
do
        chkconfig  ${service} on 
	service ${service} restart 
done

echo -e " - UPDATING MYSQL-SERVER ROOT PASSWORD"
echo -ne "Please type your Mysql password: "
read -s NEWPASSWORD
echo -ne "Please Re-type your new password: "
read  -s CONFIRMPASSWORD


if [ -z ${NEWPASSWORD} ] && [  -z ${CONFIRMPASSWORD} ];then
	echo -e "Null Password.. Scripting Exiting..!"
	exit 1
else
	if [[ ${NEWPASSWORD} == ${CONFIRMPASSWORD} ]];then

		if mysql -u root -e "update mysql.user set Password=PASSWORD('${NEWPASSWORD}') WHERE User='root';" &> /dev/null;then
			service mysqld restart &> /dev/null
		else
			echo -e "Failed To Update Mysql-server Password"
			echo -e "Script Exiting....!"
			exit;
		fi
	else
		echo -e "Password Do Not Match.. Scripting Exiting..!"
		exit 1

	fi
fi


echo -e " - RELOADING PRIVILEGES...!"
mysql -u root -p${CONFIRMPASSWORD} -e "FLUSH PRIVILEGES"
sleep 2

echo -e " - RESTARTING MYSQLD...!"
service mysqld restart &> /dev/null

