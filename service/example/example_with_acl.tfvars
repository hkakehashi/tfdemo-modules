dns_zone        = "hkakehas.tokyo"
domain          = "terratest.hkakehas.tokyo"
papertrail_addr = "xxx.papertrailapp.com"
papertrail_port = 12345
enable_acl      = true
allowed_ips = [
  { ip : "192.168.1.0", subnet : 24, comment : "tokyo office" },
  { ip : "192.168.2.0", subnet : 28, comment : "fukuoka office" },
]