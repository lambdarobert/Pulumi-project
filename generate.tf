terraform {
    required_providers {
        aws = {
            source = "hashicorp/aws"
            version = "~> 3.0"
        }
    }
}

provider "aws" {
    region = "us-west-2"
}

resource "aws_security_group" "EC2SecurityGroup" {
    description = "Created by the LIW for EFS at 2023-06-04T04:42:29.564Z"
    name = "instance-sg-3"
    tags = {}
    vpc_id = "vpc-ENTERID"
    egress {
        cidr_blocks = [
            "0.0.0.0/0"
        ]
        from_port = 0
        protocol = "-1"
        to_port = 0
    }
    egress {
        security_groups = [
            "${aws_security_group.EC2SecurityGroup2.id}"
        ]
        description = "Created by the LIW for EFS at 2023-06-04T04:42:30.599Z"
        from_port = 2049
        protocol = "tcp"
        to_port = 2049
    }
}

resource "aws_security_group" "EC2SecurityGroup2" {
    description = "Created by the LIW for EFS at 2023-06-04T04:42:29.248Z"
    name = "efs-sg-3"
    tags = {}
    vpc_id = "ENTERVPC"
    ingress {
        security_groups = [
            "sg-ENTERSGID"
        ]
        description = "Created by the LIW for EFS at 2023-06-04T04:42:30.033Z"
        from_port = 2049
        protocol = "tcp"
        to_port = 2049
    }
    egress {
        cidr_blocks = [
            "0.0.0.0/0"
        ]
        from_port = 0
        protocol = "-1"
        to_port = 0
    }
}

resource "aws_security_group" "EC2SecurityGroup3" {
    description = "launch-wizard-2 created 2023-06-04T04:39:35.499Z"
    name = "launch-wizard-2"
    tags = {}
    vpc_id = "vpc-ENTERVPCID"
    ingress {
        cidr_blocks = [
            "0.0.0.0/0"
        ]
        from_port = 22
        protocol = "tcp"
        to_port = 22
    }
    ingress {
        cidr_blocks = [
            "0.0.0.0/0"
        ]
        from_port = 25565
        protocol = "tcp"
        to_port = 25565
    }
    ingress {
        cidr_blocks = [
            "0.0.0.0/0"
        ]
        from_port = 25565
        protocol = "udp"
        to_port = 25565
    }
    egress {
        cidr_blocks = [
            "0.0.0.0/0"
        ]
        from_port = 0
        protocol = "-1"
        to_port = 0
    }
}

resource "aws_cloudfront_distribution" "CloudFrontDistribution" {
    aliases = [
        "ENTERDOMAINNAME"
    ]
    origin {
        custom_origin_config {
            http_port = 80
            https_port = 443
            origin_keepalive_timeout = 5
            origin_protocol_policy = "http-only"
            origin_read_timeout = 30
            origin_ssl_protocols = [
                "TLSv1.2"
            ]
        }
        domain_name = "ENTERDOMAINNAME.s3-website-us-west-2.amazonaws.com"
        origin_id = "ENTERDOMAINNAME.s3-website-us-west-2.amazonaws.com"
        
        origin_path = ""
    }
    default_cache_behavior {
        allowed_methods = [
            "HEAD",
            "GET"
        ]
        compress = true
        smooth_streaming  = false
        target_origin_id = "ENTERDOMAINNAME.s3-website-us-west-2.amazonaws.com"
        viewer_protocol_policy = "redirect-to-https"
    }
    comment = ""
    price_class = "PriceClass_100"
    enabled = true
    viewer_certificate {
        acm_certificate_arn = "arn:aws:acm:us-east-1ENTERCERTIFICATEID"
        cloudfront_default_certificate = false
        minimum_protocol_version = "TLSv1.2_2021"
        ssl_support_method = "sni-only"
    }
    restrictions {
        geo_restriction {
            restriction_type = "none"
        }
    }
    web_acl_id = "arn:aws:wafv2:us-east-1:ENTERACL:global/webacl/CreatedByCloudFront-ENTERID"
    http_version = "http2and3"
    is_ipv6_enabled = true
}

resource "aws_s3_bucket" "S3Bucket" {
    bucket = "ENTERBUCKETNAME"
}

resource "aws_route53_record" "Route53RecordSet" {
    name = "api.ENTERDOMAINNAME."
    type = "A"
    alias {
        name = "RECORDID.execute-api.us-west-2.amazonaws.com."
        zone_id = "ENTERZONEID"
        evaluate_target_health = true
    }
    zone_id = "ENTERZONEID"
}

resource "aws_route53_record" "Route53RecordSet2" {
    name = "ENTERDOMAINNAME."
    type = "A"
    ttl = 60
    records = [
        "ENTEREC2"
    ]
    zone_id = "ENTERZONEID"
}

resource "aws_instance" "EC2Instance" {
    ami = "ENTERAMI"
    instance_type = "c5d.large"
    key_name = "ENTERKEYNAME"
    availability_zone = "us-west-2d"
    tenancy = "default"
    subnet_id = "ENTERSUBNETID"
    ebs_optimized = true
    vpc_security_group_ids = [
        "${aws_security_group.EC2SecurityGroup3.id}",
        "${aws_security_group.EC2SecurityGroup.id}"
    ]
    source_dest_check = true
    root_block_device {
        volume_size = 8
        volume_type = "gp2"
        delete_on_termination = true
    }
    user_data = "ENTERUSERDATA"
    tags = {
        Name = "ENTERINSTANCENAME"
    }
}

resource "aws_eip" "EC2EIP" {
    vpc = true
    instance = "ENTEREC2INSTANCEID"
}

resource "aws_eip_association" "EC2EIPAssociation" {
    allocation_id = "ENTERALLOCATIONID"
    instance_id = "ENTERINSTANCEID"
    network_interface_id = "ENTERINTERFACEID"
    private_ip_address = "ENTERPRIVATEID"
}

resource "aws_volume_attachment" "EC2VolumeAttachment" {
    volume_id = "ENTERVOLUMEID"
    instance_id = "ENTERINSTANCEID"
    device_name = "/dev/sda1"
}

resource "aws_network_interface_attachment" "EC2NetworkInterfaceAttachment" {
    network_interface_id = "ENTERINTERFACEID"
    device_index = 0
    instance_id = "ENTERINSTANCEID"
}

resource "aws_lambda_function" "LambdaFunction" {
    description = ""
    environment {
        variables {
            INSTANCE = "ENTERINSTANCEID"
            AUTHORIZATION = "ENTERRANDOMSTRING"
        }
    }
    function_name = "ec2setup"
    handler = "lambda_function.lambda_handler"
    architectures = [
        "x86_64"
    ]
    s3_bucket = "awslambda-us-west-2-tasks"
    s3_key = "/snapshots/ec2setup-ENTERS3KEY"
    s3_object_version = "JlzhSlfTLE_Ix4_8MvNoRyLOHdyPBCTe"
    memory_size = 1769
    role = "arn:aws:iam::ENTERIAMPOLICY"
    runtime = "python3.9"
    timeout = 6
    tracing_config {
        mode = "PassThrough"
    }
}

resource "aws_lambda_function" "LambdaFunction2" {
    description = ""
    environment {
        variables {
            EC2URL = "ENTERSTARTENDPOINTURL"
            HCAPTCHA = "ENTERHCAPTCHASECRET"
            AUTHORIZATION = "ENTERRANDOMSTRING"
        }
    }
    function_name = "ENTERFUNCTIONNAME"
    handler = "hello.handler"
    architectures = [
        "x86_64"
    ]
    s3_bucket = "awslambda-us-west-2-tasks"
    s3_key = "ENTERS3KEYLOCATION"
    s3_object_version = "ENTEROBJECTVERSION"
    memory_size = 1769
    role = "arn:aws:iam::ENTERIAMID"
    runtime = "provided.al2"
    timeout = 6
    tracing_config {
        mode = "PassThrough"
    }
}

resource "aws_lambda_function" "LambdaFunction3" {
    description = ""
    environment {
        variables {
            CONNECT_IP = "ENTERIP"
            INSTANCE = "ENTEREC2INSTANCE"
        }
    }
    function_name = "cs312statuslambda"
    handler = "lambda_function.lambda_handler"
    architectures = [
        "x86_64"
    ]
    s3_bucket = "awslambda-us-west-2-tasks"
    s3_key = "ENTERS3KEY"
    s3_object_version = "ENTEROBJECTVERSION"
    memory_size = 128
    role = "arn:aws:iam::ENTERPOLICY"
    runtime = "python3.10"
    timeout = 3
    tracing_config {
        mode = "PassThrough"
    }
}

resource "aws_lambda_permission" "LambdaPermission" {
    action = "lambda:InvokeFunction"
    function_name = "${aws_lambda_function.LambdaFunction.arn}"
    principal = "apigateway.amazonaws.com"
    source_arn = "arn:aws:execute-api:ENTERAPINAME"
}

resource "aws_lambda_permission" "LambdaPermission2" {
    action = "lambda:InvokeFunctionUrl"
    function_name = "${aws_lambda_function.LambdaFunction.arn}"
    principal = "*"
}

resource "aws_lambda_permission" "LambdaPermission3" {
    action = "lambda:InvokeFunction"
    function_name = "${aws_lambda_function.LambdaFunction2.arn}"
    principal = "apigateway.amazonaws.com"
    source_arn = "arn:aws:execute-api:us-west-2:ENTERAPINAME/*/*/server/start"
}

resource "aws_lambda_permission" "LambdaPermission4" {
    action = "lambda:InvokeFunction"
    function_name = "${aws_lambda_function.LambdaFunction3.arn}"
    principal = "apigateway.amazonaws.com"
    source_arn = "arn:aws:execute-api:us-west-2:ENTERAPINAME/*/*/server/status"
}

resource "aws_efs_file_system" "EFSFileSystem" {
    performance_mode = "generalPurpose"
    encrypted = true
    kms_key_id = "arn:aws:kms:us-west-2:ENTERKMSKEY"
    throughput_mode = "elastic"
    tags = {
        Name = "ENTERTAGNAME"
    }
}

resource "aws_apigatewayv2_api" "ApiGatewayV2Api" {
    api_key_selection_expression = "$request.header.x-api-key"
    description = "Created by AWS Lambda"
    protocol_type = "HTTP"
    route_selection_expression = "$request.method $request.path"
    cors_configuration {
        allow_origins = [
            "*"
        ]
    }
    tags = {}
}

resource "aws_route53_zone" "Route53HostedZone" {
    name = "ENTERDOMAIN"
}

resource "aws_route53_zone" "Route53HostedZone2" {
    name = "ENTERARECORD"
}

resource "aws_route53_zone" "Route53HostedZone3" {
    name = "local."
}

resource "aws_route53_record" "Route53RecordSet3" {
    name = "ENTERDOMAINNAME"
    type = "A"
    alias {
        name = "ENTERNAME"
        zone_id = "ENTERZONEID"
        evaluate_target_health = false
    }
    zone_id = "ENTERZONEID"
}

resource "aws_route53_record" "Route53RecordSet4" {
    name = "ENTERDOMAIN"
    type = "NS"
    ttl = 172800
    records = [
        "ns-818.awsdns-38.net.",
        "ns-100.awsdns-12.com.",
        "ns-1668.awsdns-16.co.uk.",
        "ns-1305.awsdns-35.org."
    ]
    zone_id = "ENTERZONEID"
}

resource "aws_route53_record" "Route53RecordSet5" {
    name = "ENTERDOMAINNAME"
    type = "SOA"
    ttl = 900
    records = [
        "ns-818.awsdns-38.net. awsdns-hostmaster.amazon.com. 1 7200 900 1209600 86400"
    ]
    zone_id = "ENTERDOMAINNAME"
}

resource "aws_route53_record" "Route53RecordSet6" {
    name = "ENTERAPINAME"
    type = "CNAME"
    ttl = 300
    records = [
        "ENTERVALIDATION"
    ]
    zone_id = "ENTERZONEID"
}

resource "aws_route53_record" "Route53RecordSet7" {
    name = "ENTERSERVERIP"
    type = "A"
    alias {
        name = "ENTERCLOUDFRONT"
        zone_id = "ENTERZONEID"
        evaluate_target_health = false
    }
    zone_id = "ENTERZONEID"
}

resource "aws_route53_record" "Route53RecordSet8" {
    name = "ENTERSERVERIP"
    type = "CNAME"
    ttl = 300
    records = [
        "ENTERVALIDATION"
    ]
    zone_id = "ENTERZONEID"
}
