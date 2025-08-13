variable "extra_packages" {
  description = "The additional packages to install"
  type        = list(string)
  default     = []
}

output "config" {
  value = jsonencode({
    contents = {
      packages = var.extra_packages
    }
    accounts = {
      groups = [
        {
          groupname = "postfix"
          gid       = 101
        },
        {
          groupname = "postdrop"
          gid       = 102
        }
      ]
      users = [
        {
          username = "postfix"
          uid      = 100
          gid      = 101
        },
        {
          username = "vmail"
          uid      = 101
          gid      = 102
        }
      ]
      run-as = 0
    }
    # No entrypoint - match upstream exactly
    cmd = ["/bin/sh", "-c", "/scripts/run.sh"]
    work-dir = "/tmp"
    exposed-ports = ["587"]
    volumes = [
      "/var/spool/postfix",
      "/etc/postfix",
      "/etc/rspamd"
    ]
    paths = [
      {
        path        = "/var/spool/postfix"
        type        = "directory"
        uid         = 0
        gid         = 0
        permissions = 755
        recursive   = true
      },
      {
        path        = "/var/lib/postfix"
        type        = "directory"
        uid         = 100
        gid         = 101
        permissions = 755
        recursive   = true
      },
      {
        path        = "/etc/postfix"
        type        = "directory"
        uid         = 0
        gid         = 0
        permissions = 755
        recursive   = true
      },
      {
        path        = "/etc/rspamd"
        type        = "directory"
        uid         = 0
        gid         = 0
        permissions = 755
        recursive   = true
      },
      {
        path        = "/scripts"
        type        = "directory"
        uid         = 0
        gid         = 0
        permissions = 755
        recursive   = true
      },
      {
        path        = "/var/log"
        type        = "directory"
        uid         = 0
        gid         = 0
        permissions = 755
        recursive   = true
      }
    ]
    healthcheck = {
      test         = ["CMD-SHELL", "/scripts/healthcheck.sh"]
      interval     = "30s"
      timeout      = "5s"
      start-period = "10s"
      retries      = 3
    }
  })
}