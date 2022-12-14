 # AWS_Testworks

## playq

### Goals
Provision via Terraform an AWS Autoscaling Group and Application Load Balancer in AWS us-east-1 region.

#### Applying 

After applying you should get a SUCCESS response with the DNS name of your load balancer to connect to the application.
```bash

Apply complete! Resources: 11 added, 0 changed, 0 destroyed.

Outputs:

alb_dns_name = playq-2019-181606912.us-east-1.elb.amazonaws.com
```
Application path is "index.html". You should transparently specify the path "index.html"

#### Testing
in case of requesting site root you will get HTTP 500
```bash
% curl -v http://playq-2019-181606912.us-east-1.elb.amazonaws.com           
*   Trying 52.0.198.161:80...
* Connected to playq-2019-181606912.us-east-1.elb.amazonaws.com (52.0.198.161) port 80 (#0)
> GET / HTTP/1.1
> Host: playq-2019-181606912.us-east-1.elb.amazonaws.com
> User-Agent: curl/7.84.0
> Accept: */*
> 
* Mark bundle as not supporting multiuse
< HTTP/1.1 500 Internal Server Error
< Server: awselb/2.0
< Date: Wed, 14 Dec 2022 9:15:14 GMT
< Content-Type: text/plain; charset=utf-8
< Content-Length: 21
< Connection: keep-alive
< 
* Connection #0 to host playq-2019-181606912.us-east-1.elb.amazonaws.com left intact
Internal Server Error
```

in case of requesting specific existing file you will get HTTP 200
```bash
% curl -v http://playq-2019-181606912.us-east-1.elb.amazonaws.com/index.html 
*   Trying 52.22.94.200:80...
* Connected to playq-2019-181606912.us-east-1.elb.amazonaws.com (52.22.94.200) port 80 (#0)
> GET /index.html HTTP/1.1
> Host: playq-2019-181606912.us-east-1.elb.amazonaws.com
> User-Agent: curl/7.84.0
> Accept: */*
> 
* Mark bundle as not supporting multiuse
< HTTP/1.1 200 OK
< Date: Wed, 14 Dec 2022 10:54:12 GMT
< Content-Type: text/html; charset=UTF-8
< Content-Length: 144
< Connection: keep-alive
< Server: Apache/2.4.54 ()
< Upgrade: h2,h2c
< Last-Modified: Wed, 14 Dec 2022 09:14:53 GMT
< ETag: "90-5efc62b5c54c2"
< Accept-Ranges: bytes
< 
<!DOCTYPE html>
<html>
<head>
<title>Hello World from PlayQ Test</title>
</head>
<body>

<h1>Hello World from PlayQ Test</h1>


</body>
</html>
* Connection #0 to host playq-2019-181606912.us-east-1.elb.amazonaws.com left intact
```

#### Comments
as for the hint to use "lookup" function to choose the correct AMI based upon the region - usage of this function for additional filtering by region is useless, because provider "aws" is already restricted by region, and other nested resources follow this param, so in my humble opinion it would be best to use of data source "aws_ami" for this case
