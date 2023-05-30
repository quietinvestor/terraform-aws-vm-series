# Palo Alto Networks VM-Series in AWS
## Table of Contents

1. [Overview](#1-overview)
2. [Requirements](#2-requirements)
3. [Download](#3-download)
4. [Install](#4-install)
5. [Run](#5-run)
6. [Apply Changes](#6-apply-changes)
7. [Destroy](#7-destroy)
8. [Variables](#8-variables)
9. [Security Groups](#9-security-groups)
10. [Key Pairs](#10-key-pairs)
11. [Root Volume Encryption](#11-root-volume-encryption)
12. [IAM Roles](#12-iam-roles)
13. [Tags](#13-tags)

## 1. Overview

A Terraform template for deploying one or multiple Palo Alto Networks VM-series firewalls in AWS.

## 2. Requirements

- [Download](https://aws.amazon.com/cli/), [install](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html) and [configure](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-quickstart.html) the AWS CLI tool.
- [Download](https://www.terraform.io/downloads) and [install](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli) Terraform.
- [Download](https://git-scm.com/downloads) and [install](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git) git.

## 3. Download

To download all the required Terraform files, input the below commands from the command line:

```
git clone https://github.com/quietinvestor/terraform-aws-vm-series.git
```

## 4. Install

To install the Terraform AWS provider, while still inside the `terraform` directory, input the below commands from the command line:

```
cd terraform-aws-vm-series
terraform init
```

## 5. Run

Prior to executing the Terraform code and creating all the necessary AWS resources to deploy the VM-series firewalls, while still inside the `terraform-aws-vm-series` directory, it is recommended to input the below command from the command line to view the planned output of the AWS resources you are about to generate without actually creating them:

```
terraform plan
```

After inputting the above command, you will be prompted to provide the values for the necessary input variables, after which the planned output will be displayed.

If the result from the above is satisfactory, you can go ahead and input the below command from the command line to actually create all the necessary AWS resources to deploy the VM-series firewalls:

```
terraform apply
```

Once again, after inputting the above command, you will be prompted to provide the values for the necessary input variables, after which the planned output will be displayed, alongside a prompt to continue, where you must type `yes` if you would like to go ahead and create all the necessary AWS resources to deploy the VM-series firewalls.

## 6. Apply Changes

Please note that Terraform just tracks changes in the infrastructure generated by its code. For example, if you run `terraform apply` and then manually modify a Security Group Rule from the AWS Console, Terraform will not detect the change when you run again `terraform apply`. Therefore, the best way to modify the infrastructure is by modifying the corresponding Terraform code, then running `terraform apply` and typing in `yes` at the prompt to continue, once you have confirmed that the planned changes reflect what you would like to apply.

## 7. Destroy

When the time comes to delete all your infrastructure, you can do so by running the below command:

```
terraform destroy
```

After inputting the above command, terraform will display details of all the resources that will be destroyed and will prompt you to continue. If you type `yes`, it will go ahead and destroy all the resources managed by Terraform.

Please note that Terraform just tracks changes in the infrastructure generated by its code. For example, if you run `terraform apply` and then manually modify a Security Group Rule from the AWS Console, Terraform will not detect the change when you run `terraform destroy` and will consequently not destroy it. Therefore, the best way to modify the infrastructure is by modifying the corresponding Terraform code, then running `terraform apply` and typing in `yes` at the prompt to continue, once you have confirmed that the planned changes reflect what you would like to apply. As a result, if you later run `terraform destroy`, it will also delete the newly-created Security Group Rule.

## 8. Variables

Please refer to the table below for a list of the user-input variables:

| Variable | Description | Example Input | Required? |
| :--- | :--- | :---: | :---: |
| **authcode** | VM-series auth code. This setting already modifies the `bootstrap options` as necessary, so it is not necessary to include this option in them additionally. | _D1234567_ | No |
| **az_count** | Number of Availability Zones (AZ) in which you would like to deploy the VM-series firewalls. The number cannot be higher than the number of AZs available for the chosen AWS region. The VM-series firewalls will be deployed in round robin across the AZs. For example, if `region = "eu-central-1"`, `az_count = 3` and `firewall_count = 4`, `fw1` will be deployed in AZ `eu-central-1a`, `fw2` will be deployed in AZ `eu-central-1b`, `fw3` will be deployed in AZ `eu-central-1c`, `fw4` will be deployed in AZ `eu-central-1a` and so forth. | _3_ | Yes |
| **bootstrap_options** | [Bootstrap options](https://docs.paloaltonetworks.com/vm-series/10-2/vm-series-deployment/bootstrap-the-vm-series-firewall/create-the-init-cfgtxt-file/init-cfgtxt-file-components) to include as user data, separated by semi-colons. Some bootstrap options are already set by default, such as `type=dhcp-client`, whereas others are already managed through other variables, such as `authcodes=`, `hostname=` and `op-command-modes=management-interface-swap`. Hence, this variable is best used to include other bootstrap options not mentioned here, such as those of the example input. If you would like to modify the defaults, please do so in the `locals.tf` file under `firewall_settings > bootstrap_options`. | _panorama-server=1.1.1.1;panorama-server-2=2.2.2.2_ | No |
| **encrypt_root_volume** | Specify whether you would like to encrypt the VM-series firewall's root EBS volume using a Customer Master Key (CMK) with AWS Key Management Service (KMS). | _yes_ | Yes |
| **firewall_count** | Number of VM-series firewalls to deploy. For safety, this number is capped by default at 4 VM-series firewalls. However, if you need to deploy more firewalls, simply edit the upper bound number of `4` in the `variables.tf` file under `(var.firewall_count <= 4)` | _2_ | Yes |
| **firewall_name** | Firewall name that will be used both for the virtual machine name, its associated resources and hostname. Please note that this will be appended to the user-input `username` and `project_name` variables to form together a final name with the format `<username>-tf-<project_name>-<firewall_name><firewall_index_number>`, e.g. `testuser-tf-vm-series-fw1`. It is therefore not necessary to include the `hostname=` under `bootstrap options`, as this setting already modifies it, together with the other variables mentioned as per the previous example. | _fw_ | Yes |
| **instance_type** | AWS [instance type](https://docs.paloaltonetworks.com/vm-series/10-2/vm-series-performance-capacity/vm-series-performance-capacity/vm-series-on-aws-models-and-instances) supported for VM-series firewalls. | _m5.large_ | Yes |
| **management_interface_swap** | Specify whether you want to [swap the management and untrust interfaces](https://docs.paloaltonetworks.com/vm-series/10-2/vm-series-deployment/set-up-the-vm-series-firewall-on-aws/about-the-vm-series-firewall-on-aws/management-interface-mapping-for-use-with-amazon-elb), such that the virtual machine untrust interface becomes eth0 and the management interface becomes eth1. This is an AWS requirement when working with load balancers, as they only support sending traffic to eth0. This setting already modifies the `bootstrap options` as necessary, so it is not necessary to include this option in them additionally. | _yes_ | Yes |
| **my_ip_list** | List of IPs in CIDR format to add to Security Group Rules to allow inbound ICMP, SSH and HTTPS access to the firewall. This should be in a string list format, as per the example input. | _["1.1.1.1/32", "2.2.2.2/32"]_ | Yes |
| **panos_version** | PAN-OS version you would like to use to deploy your VM-series firewalls. Please make sure beforehand that there is an Amazon Machine Image (AMI) that uses that PAN-OS version available in the AWS marketplace for the region where you would like to deploy it. | _10.2.2-h2_ | Yes |
| **project_name** | Project name that will be used both for the virtual machine name, its associated resources and hostname. This could be, for example, the case number for the replication. Please note that this will be appended to the user-input `username` and prepended to the `firewall_name` variables to form together a final name with the format `<username>-tf-<project_name>-<firewall_name><firewall_index_number>`, e.g. `testuser-tf-vm-series-fw1`. It is therefore not necessary to include the `hostname=` under `bootstrap options`, as this setting already modifies it, together with the other variables mentioned as per the previous example. | _vm-series_ | Yes |
| **region** | [AWS region](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/using-regions-availability-zones.html#concepts-available-regions) in which to deploy the VM-series firewalls. This will also determine which Availability Zones (AZ) the VM-series firewalls may be deployed on. Please refer to `az_count` above for more information on AZs and firewall deployment. | _eu-central-1_ | Yes |
| **username** | User name that will be used both for the virtual machine name, its associated resources and hostname. Please note that this will be prepended to the user-input `username` and `firewall_name` variables to form together a final name with the format `<username>-tf-<project_name>-<firewall_name><firewall_index_number>`, e.g. `testuser-tf-vm-series-fw1`. It is therefore not necessary to include the `hostname=` under `bootstrap options`, as this setting already modifies it, together with the other variables mentioned as per the previous example. | _testuser_ | Yes |
| **vpc_cidr** | Network to use for creating the AWS VPC and its 3 subnets (management, trust and untrust), input in CIDR format. Currently, only /16 is supported for the VPC and /24 for its 3 default subnets. Thus, a VPC of `10.100.0.0/16`, would automatically generate a management subnet of `10.100.0.0/24`, an untrust subnet of `10.100.1.0/24` and a trust subnet of `10.100.2.0/24`. | _10.100.0.0/16_ | Yes |

Please note that, for safety, consistency and predictability, all user-input variables go through input validation to a lesser or greater extent, depending on the individual variable. However, it is not perfect and does not always prevent from introducing a bogus value that may cause errors at runtime when deploying the VM-series firewalls (e.g. using a fake `authcode` might yield bootstrapping errors on boot).

### terraform.tfvars

For convenience, rather than inputting all required variables when prompted every time that you run `terraform plan` or `terraform apply`, it is recommend to create a file named `terraform.tfvars` alongside the rest of the downloaded Terraform code under `terraform-aws-vm-series`, where you can include the variable names and assign the values you wish to them, separating each variable with a new line. For example,

```
authcode                  = ""
az_count                  = 3
bootstrap_options         = ""
encrypt_root_volume       = "yes"
firewall_count            = 3
firewall_name             = "fw"
instance_type             = "m5.large"
management_interface_swap = "yes"
my_ip_list                = ["1.1.1.1/32", "2.2.2.2/32"]
panos_version             = "10.2.2-h2"
project_name              = "vm-series"
region                    = "eu-central-1"
username                  = "testuser"
vpc_cidr                  = "10.100.0.0/16"
```

## 9. Security Groups

The network interfaces associated to each subnet of management, trust and untrust have got corresponding Security Groups associated to them and named accordingly. The Security Group Rules contained within each of them are the defaults used by the author of this code, but feel free to add or remove rules as you wish by editing the `aws_security_group_rule` resources contained in the `security_groups.tf` file.

By default,
- Outbound internet access is allowed on the management and untrust interfaces.
- Inbound ICMP traffic is allowed within the management, untrust and trust subnets.
- Inbound ICMP, SSH and HTTPS traffic is allowed on the management interface from `my_ip_list`.
- Inbound ICMP, SSH, HTTP and HTTPS traffic is allowed on the untrust interface from `my_ip_list`.
- Inbound HTTPS traffic is allowed on the trust interface from within the subnet.

As cautioned in the [6. Apply Changes](#6-apply-changes) and [7. Destroy](#7-destroy) sections above, please make sure that you apply any modifications to Security Group Rules or other AWS resources by editing the corresponding Terraform code and using `terraform apply`, instead of directly via the AWS console. Otherwise, the changes will not be tracked by Terraform and they will not be deleted by using `terraform destroy` either.

## 10. Key Pairs

### A. SSH

Given that SSH key pairs do not persist across regions, as a best practice, a new SSH key pair is created per project, named `<username>-tf-<project_name>-key`, e.g. `testuser-tf-vm-series-key`.

In order to create the key pair, please make sure that you have created beforehand a key pair with the below characteristics:
- OpenSSH (`*.pem`) format
- RSA algorithm
- At least 2048-bit key size

The public key used to create the key pair should be stored in a file named `ssh-key.pub` under the same directory as the rest of `*.tf` files, i.e. `terraform-aws-vm-series`.

### B. Customer Master Key (CMK) Key Management Service (KMS)

By default, the CMK KMS key is created for a single region, corresponding to that of the project. However, the `multi-region = true` argument may be passed to the `aws_kms_key.ebs_root` resource in the `key_pairs.tf` file.

Similarly, the default encryption algorithm is set to `SYMMETRIC_DEFAULT` (AES-256-GCM, see [AWS KMS Developer Guide](https://docs.aws.amazon.com/kms/latest/developerguide/overview.html) for more details), but can be modified using the `customer_master_key_spec` argument in the `aws_kms_key.ebs_root` resource in the `key_pairs.tf` file.

The waiting period after which AWS deletes the CMK KMS key can be between 7 and 30 days. It is set using the `deletion_window_in_days` argument in the `aws_kms_key.ebs_root` resource in the `key_pairs.tf` file. 30 days is set as the default value.

Finally, for ease of reference, an alias is created for the CMK KMS key with the format `<username>-tf-<project_name>-kms`. For example, `testuser-tf-vm-series-kms`.

## 11. Root Volume Encryption

As a security best practice, you may choose to encrypt the VM-series firewall's root EBS volume with AWS CMK KMS (see [10. Key pairs](#10-key-pairs) above). To do so, simply set the `encrypt_root_volume` variable to `yes`.

## 12. IAM Roles

If the VM-series firewall EC2 instances require an IAM role and instance profile for [VM Information Sources](https://docs.paloaltonetworks.com/pan-os/10-2/pan-os-web-interface-help/device/device-vm-information-sources/settings-to-enable-vm-information-sources-for-aws-vpc) or [Active/Passive High Availability](https://docs.paloaltonetworks.com/vm-series/10-2/vm-series-deployment/set-up-the-vm-series-firewall-on-aws/high-availability-for-vm-series-firewall-on-aws/iam-roles-for-ha), it can be created in the `iam_roles.tf` file.

By default, an IAM role and instance profile for [VM Information Sources](https://docs.paloaltonetworks.com/pan-os/10-2/pan-os-web-interface-help/device/device-vm-information-sources/settings-to-enable-vm-information-sources-for-aws-vpc) is created and attached to every VM-series firewall EC2 instance.

## 13. Tags

In order to make all resources created by Terraform easily identifiable and searchable, the `Name` tag has been applied to all of them, prepended with at least the `<username>-tf-<project_name>-`. For example, the management subnet route table would be tagged with the name `testuser-tf-vm-series-rt-mgmt`, where `tf` stands for Terraform.
