#!/bin/bash
yum -y update
yum -y install httpd
echo "<!DOCTYPE html>
<html>
<head>
<title>Hello World from PlayQ Test</title>
</head>
<body>

<h1>Hello World from PlayQ Test</h1>


</body>
</html>" > /var/www/html/index.html
systemctl start httpd
systemctl enable httpd
