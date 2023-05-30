variable "authcode" {
  type        = string
  description = "VM-Series Auth Code"

  validation {
    # WARNING: This does not prevent from entering invalid auth codes
    # Auth codes can be empty
    condition     = can(regex("(^$|^[A-Z][0-9]{7}$)", var.authcode))
    error_message = "Auth codes contain exactly one capital letter, followed by 7 digits."
  }
}

variable "az_count" {
  type        = number
  description = "Total number of Availability Zones (AZ) for VM-series firewall deployment"

  # Reference:
  # https://aws.amazon.com/about-aws/global-infrastructure/
  validation {
    condition     = (var.az_count > 0) && (var.az_count <= 6)
    error_message = "The total number of Availability Zones (AZ) for VM-series firewall deployment must be greater than 0 and less than or equal to 6, the maximum depending on the AWS region. AWS does not support more than 6 AZs per region."
  }
}

variable "bootstrap_options" {
  type        = string
  description = "VM-Series bootstrap options to include in instance user data, separated by semicolons ';', e.g. \"type=dhcp-client;op-command-modes=mgmt-interface-swap\".\n\nSee the link below for a list of valid key-value pairs:\n\nhttps://docs.paloaltonetworks.com/vm-series/10-2/vm-series-deployment/bootstrap-the-vm-series-firewall/create-the-init-cfgtxt-file/init-cfgtxt-file-components"

  # WARNING: This does not prevent the input of invalid bootstrap options
  # Reference:
  # https://docs.paloaltonetworks.com/vm-series/10-2/vm-series-deployment/bootstrap-the-vm-series-firewall/create-the-init-cfgtxt-file/init-cfgtxt-file-components
  validation {
    condition     = can(regex("^[0-9a-z-\\.,;=\\/]*$", var.bootstrap_options))
    error_message = "bootstrap_options can only contain lowercase characters, numbers or the following symbols: .,;=/"
  }
}

variable "encrypt_root_volume" {
  type        = string
  description = "Encrypt root volume? [yes/no]"

  validation {
    condition     = var.encrypt_root_volume != ""
    error_message = "encrypt_root_volume cannot be empty"
  }

  validation {
    condition     = can(regex("^[Yy](?:[Ee][Ss])?$|^[Nn][Oo]?$", var.encrypt_root_volume))
    error_message = "Please input \"yes\" or \"no\""
  }
}

variable "firewall_count" {
  type        = number
  description = "Total number of Palo Alto Networks VM-series firewalls to deploy"

  validation {
    condition     = (var.firewall_count > 0) && (var.firewall_count <= 4) // Edit this last number, if you need to deploy more firewalls
    error_message = "For safety, you can only deploy a maximum of 4 VM-Series firewalls. If you would like to deploy more, edit the maximum number for the firewall_count variable in variables.tf"
  }
}

variable "firewall_name" {
  type        = string
  description = "Palo Alto Networks VM-series firewall name to prefix its index number"

  validation {
    condition     = can(regex("^[0-9a-z-]+$", var.firewall_name))
    error_message = "firewall_name cannot be empty and can only contain lowercase characters, hyphens '-' or numbers. If you create more than 1 firewall, numbering will be added at the end of the name automatically"
  }

  validation {
    condition     = length(var.firewall_name) <= 16
    error_message = "firewall_name cannot be longer than 16 characters"
  }
}

variable "instance_type" {
  # Input validation done using aws_ec2_instance_types data
  # as a lifecycle precondition when creating the instances
  type        = string
  description = "AWS instance type, e.g. m5.large"
}

variable "license_product_code" {
  type        = string
  description = "AWS Amazon Machine Image (AMI) product code for VM-Series license type, default is BYOL"

  # Reference:
  # https://docs.paloaltonetworks.com/vm-series/10-2/vm-series-deployment/set-up-the-vm-series-firewall-on-aws/deploy-the-vm-series-firewall-on-aws/obtain-the-ami/get-amazon-machine-image-ids
  default = "6njl1pau431dv1qxipg63mvah"

  # WARNING: This does not prevent the input of invalid AMI product codes
  # AWS does not appear to provide a standard format against which
  # to validate AMI product codes in their documentation
  validation {
    condition     = can(regex("^[0-9a-z]+$", var.license_product_code))
    error_message = "license_product_code cannot be empty and can only contain lowercase characters or numbers"
  }
}

variable "management_interface_swap" {
  type        = string
  description = "Swap management interface? [yes/no]"

  validation {
    condition     = var.management_interface_swap != ""
    error_message = "management_interface_swap cannot be empty"
  }

  validation {
    condition     = can(regex("^[Yy](?:[Ee][Ss])?$|^[Nn][Oo]?$", var.management_interface_swap))
    error_message = "Please input \"yes\" or \"no\""
  }
}

variable "my_ip_list" {
  type        = list(string)
  description = "List of my IPs from which to access devices"

  validation {
    condition     = alltrue([for ip in var.my_ip_list : can(cidrhost(ip, 0))])
    error_message = "Please use a valid subnet value in CIDR format for all IP addresses in the list, e.g. [\"10.10.0.0/16\", \"10.20.0.0/16\"]"
  }
}

variable "panos_version" {
  type        = string
  description = "PAN-OS version, e.g. 10.2.2-h2"

  validation {
    condition     = var.panos_version != ""
    error_message = "VM-Series PAN-OS version cannot be empty"
  }

  validation {
    condition     = can(regex("(?:9\\.1\\.[0-9][0-9]?(?:-h[1-9])?)|(?:10\\.[0-2]\\.[0-9][0-9]?(?:-h[1-9])?)", var.panos_version))
    error_message = "Please input a valid and supported PAN-OS version, e.g. 10.2.2-h2"
  }
}

variable "project_name" {
  type        = string
  description = "Terraform project name"

  validation {
    condition     = can(regex("^[0-9a-z-]+$", var.project_name))
    error_message = "project_name cannot be empty and can only contain lowercase characters, hyphens '-' or numbers"
  }

  validation {
    condition     = length(var.project_name) <= 16
    error_message = "project_name cannot be longer than 16 characters"
  }
}

variable "region" {
  type        = string
  description = "AWS region"

  # Hardcoding this is terrible, but unfortunately the providers {} module
  # does not support lifecycle preconditions to use with data sources like
  # data.aws_regions. Alternatively, testing for validity with a conditional
  # expression (e.g. contains(data, var.region) ? var.region : "Error!"),
  # directly when assigning to the variable in the provider {} module
  # or a local variable, results in a cyclic reference validation error
  validation {
    condition     = contains(["af-south-1", "ap-east-1", "ap-northeast-1", "ap-northeast-2", "ap-northeast-3", "ap-south-1", "ap-southeast-1", "ap-southeast-2", "ap-southeast-3", "ca-central-1", "eu-central-1", "eu-north-1", "eu-south-1", "eu-west-1", "eu-west-2", "eu-west-3", "me-central-1", "me-south-1", "sa-east-1", "us-east-1", "us-east-2", "us-west-1", "us-west-2"], var.region)
    error_message = "region can only be one of the below:\n\n- af-south-1\n- ap-east-1\n- ap-northeast-1\n- ap-northeast-2\n- ap-northeast-3\n- ap-south-1\n- ap-southeast-1\n- ap-southeast-2\n- ap-southeast-3\n- ca-central-1\n- eu-central-1\n- eu-north-1\n- eu-south-1\n- eu-west-1\n- eu-west-2\n- eu-west-3\n- me-central-1\n- me-south-1\n- sa-east-1\n- us-east-1\n- us-east-2\n- us-west-1\n- us-west-2"
  }
}

variable "username" {
  type        = string
  description = "AWS username"

  validation {
    condition     = can(regex("^[a-z0-9]+$", var.username))
    error_message = "username cannot be empty and can only contain lowercase characters or numbers"
  }

  validation {
    condition     = length(var.username) <= 32
    error_message = "username cannot be longer than 32 characters"
  }
}

variable "vpc_cidr" {
  type        = string
  description = "VPC subnet in CIDR format, e.g. 10.0.0.0/16"

  validation {
    condition     = can(cidrhost(var.vpc_cidr, 0))
    error_message = "Please use a valid subnet value in CIDR format, e.g. 10.0.0.0/16"
  }
}