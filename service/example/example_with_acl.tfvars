dns_zone        = "hrmsk66.com"
domain          = "terratest.hrmsk66.com"
papertrail_addr = "xxx.papertrailapp.com"
papertrail_port = 12345
enable_acl      = true
allowed_ips = [
  { ip : "192.168.1.0", subnet : 24, comment : "tokyo office" },
  { ip : "192.168.2.0", subnet : 28, comment : "fukuoka office" },
]