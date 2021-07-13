source "amazon-ebs" "amazon-wordpress" {
    ami_name = "wordpress-ami"
    profile = "packer"
    instance_type = "t2.micro"
    region = "ap-northeast-1"
    source_ami = "ami-001f026eaf69770b4"
    ssh_username = "ec2-user"
}

build {
    sources = [
        "source.amazon-ebs.amazon-wordpress"
    ]

    provisioner "shell"{
        inline = [
            "sudo yum -y update",
            "sudo amazon-linux-extras install -y nginx1",
            "sudo systemctl enable nginx",
            "sudo systemctl start nginx",
            "sudo yum -y remove mariadb-libs",
            "sudo yum -y install https://dev.mysql.com/get/mysql80-community-release-el7-1.noarch.rpm",
            "sudo yum-config-manager –enable mysql80-community",
            "sudo yum -y install mysql-community-server",
            "sudo systemctl start mysqld.service",
            "sudo systemctl enable mysqld.service",
            "echo 'default_authentication_plugin=mysql_native_password' | sudo tee -a /etc/my.cnf",
            "echo 'validate_password.length=4' | sudo tee -a /etc/my.cnf",
            "echo 'validate_password.policy=LOW' | sudo tee -a /etc/my.cnf",
            "sudo systemctl restart mysqld.service",
            "echo '[client]' | tee -a ~/.my.cnf",
            "echo 'user = root' | tee -a ~/.my.cnf",
            "sudo awk '/temporary password/{ print $13 }' /var/log/mysqld.log | xargs -IXXX echo \"password ='XXX'\" | tee -a ~/.my.cnf",
            "mysql --connect-expired-password -e 'ALTER USER root@localhost IDENTIFIED BY \"wordpress\"; flush privileges;'",
            "mysql -u root -pwordpress -e 'create database wordpress;'",
            "mysql -u root -pwordpress -e 'create user admin@localhost IDENTIFIED BY \"wordpress\";'",
            "mysql -u root -pwordpress -e 'GRANT ALL ON *.* TO admin@localhost;'",
            "sudo amazon-linux-extras install -y php7.4",
            "sudo wget -P /var/www/html https://ja.wordpress.org/wordpress-5.7.2-ja.tar.gz",
            "sudo tar -xzvf /var/www/html/wordpress-5.7.2-ja.tar.gz -C /var/www/html",
            "sudo chown -R nginx:nginx /var/www/html/wordpress",
            "sudo chmod -R 755 /var/www/html/wordpress",
            "sudo chmod 777 /etc/nginx/nginx.conf",
            "sudo chmod 777 /etc/php-fpm.d/www.conf"
        ]
    }

    provisioner "file"{
        source = "files/nginx.conf"
        destination = "/etc/nginx/nginx.conf"
    }

    provisioner "file"{
        source = "files/www.conf"
        destination = "/etc/php-fpm.d/www.conf"
    }

    provisioner "shell"{
        inline = [
            "sudo chmod 644 /etc/php-fpm.d/www.conf",
            "sudo chown root:root /etc/php-fpm.d/www.conf",
            "sudo chmod 644 /etc/nginx/nginx.conf",
            "sudo chown root:root /etc/nginx/nginx.conf",
            "sudo systemctl restart nginx"
        ]
    }
}
