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
            "sudo amazon-linux-extras install -y php7.4",
            "sudo wget -P /var/www/html https://ja.wordpress.org/wordpress-5.7.2-ja.tar.gz",
            "sudo tar -xzvf /var/www/html/wordpress-5.7.2-ja.tar.gz -C /var/www/html"
        ]
    }
}