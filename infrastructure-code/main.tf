# This terraform file defines the terraform provider that will be used to deploy the IoT example architecture. 
# In this case, the IBM Cloud provider is the only provider that will be used. The two variables provide the
# means to deploy workloads. However, the APIkey and ibmid must have the permissions to deploy this archiecture's resources.

############      TERRAFORM BASICS - Provider and APIkeys    ############

# This block sets the provider and provides access credentials
provider "ibm" {
  bluemix_api_key = "${var.paasapikey}"
  softlayer_username = "${var.iaasusername}"
  softlayer_api_key  = "${var.iaasapikey}"
  region             = "${var.ibm_region}" // Will target ibmcloud region. Default: us-south.
  riaas_endpoint     = "${var.riaas_endpoint}" # Default: us-south endpoint. Required if want to specify different region.
}



#############     ACCOUNT SET UP - Organizational structure, roles and users         ############

# Create a CF Org for the IoT service and assign users to roles
# Needs permission to create org.

# resource "ibm_org" "IoT_org" {
#     name = "myIoTorg"
#     org_quota_definition_guid = "${var.IoTspace_quota}"
#     auditors = "${var.auditor}"
#     managers = "${var.manager}"
#     users = "${var.user}"
#     billing_managers = "${var.billing_manager}"
# }


# Create a CF space to deploy the IoT service and assign users to roles
# It will create space in region specified in provider block.
# Give user manager,auditor and developer access.
# `developer` access is required for creating service in that space.
resource "ibm_space" "ioT_space" {
  name        = "myIoTspace"
  org         = "${var.org}"
  # space_quota = "${var.IoTspace_quota}"  (optional) to provide space quota.
  managers    = "${var.manager}"
  auditors    = "${var.auditor}"
  developers  = "${var.developers}"
 }

#############     IOT PAAS SERVICE - deploys the IoT service         ############

# Deploy the IoT service to the org/space
resource "ibm_service_instance" "IoT_service_instance" {
  name       = "IoT_test"
  space_guid = "${ibm_space.ioT_space.id}"
  service    = "iotf-service"
  plan       = "iotf-service-free" // Lite plan
  tags       = ["IoT-service-test"]
}



#############     ACCOUNT SET UP - Organizational structure, roles and users         ############

# Create the Resource Group that is used when deploying the VPC
resource "ibm_resource_group" "IoTresourceGroup" {
  name     = "${var.resource_group}"
}

#############     NETWORK INFRASTRUCTURE - VPC, subnets, ACLs, security groups          ############

# Create A VPC in default zone. 
resource "ibm_is_vpc" "iot_on_vpc" {
  name = "terraform-IoT-vpc"
  resource_group = "${ibm_resource_group.IoTresourceGroup.id}"
}

# (Optional) This moves VPC from default zone to specified zone using a variable.
# This can be also be used in case default zone has reached max capacity.
resource "ibm_is_vpc_address_prefix" "iot_on_vpc_address_prefix" {
  name = "terraform-IoT-vpc-address-fix"
  zone = "${var.availability_zone}"
  vpc  = "${ibm_is_vpc.iot_on_vpc.id}"
  cidr = "${var.address_prefix}"
}

# This will add new rules to default security_group created for VPC.
# Rules are stateful, which means that reverse traffic in response to 
# allowed traffic is automatically permitted. So for example, a rule 
# allowing inbound TCP traffic on port 80 also allows replying outbound 
# TCP traffic on port 80 back to the originating host, without the need 
# In this case, Inbound rules with TCP port 7000 is added.
resource "ibm_is_security_group_rule" "security_group_rule_tcp" {
    group     = "${ibm_is_vpc.iot_on_vpc.default_security_group}"
    direction = "ingress"
    remote    = "${var.access_to_any_ip}"
    tcp  = {
        port_min = "${var.security_group_port}"
        port_max = "${var.security_group_port}"
    }
 }

 resource "ibm_is_security_group_rule" "security_group_rule_udp" {
    group     = "${ibm_is_vpc.iot_on_vpc.default_security_group}"
    direction = "ingress"
    remote    = "${var.access_to_any_ip}"
    udp  = {
        port_min = "${var.udp_min_port}"
        port_max = "${var.udp_max_port}"
    }
 }

# This terraform script will create subnet in VPC for VM workload.
resource "ibm_is_subnet" "iot_on_vpc_subnet" {
    name = "terraform-iot-on-vpc-subnet"
    vpc =  "${ibm_is_vpc.iot_on_vpc.id}"
    zone = "${var.availability_zone}"
    ipv4_cidr_block = "${var.subnet_cidr}" 
    network_acl = "${ibm_is_network_acl.IoTSubnetACL.id}"
}

# This will create a network ACL for the subnet in this resource group.
# The when the subnet is created, this ACL will be associated.
# This example has no limits
# Bug: throws error `invalid or unknown key: protocol`
resource "ibm_is_network_acl" "IoTSubnetACL" {
            name = "IoT-Subnet-acl"
            rules=[
            {
                name = "egress-tcp"
                action = "allow"
                source = "${var.ACLsource_egress}"
                destination = "${var.ACLdest_egress}"
                direction = "egress"
                tcp {
                  port_max = "${var.tcp_max_port}"
                  port_min = "${var.tcp_min_port}"
                }
            },
            {
                name = "ingress-tcp"
                action = "allow"
                source = "${var.ACLsource_ingress}"
                destination = "${var.ACLdest_ingress}"
                direction = "ingress"
                tcp {
                  port_max = "${var.tcp_max_port}"
                  port_min = "${var.tcp_min_port}"
                }
            },
             {
                name = "egress-udp"
                action = "allow"
                source = "${var.ACLsource_egress}"
                destination = "${var.ACLdest_egress}"
                direction = "egress"
                udp {
                  port_max = "${var.udp_max_port}"
                  port_min = "${var.udp_min_port}"
                }
            },
            {
                name = "ingress-udp"
                action = "allow"
                source = "${var.ACLsource_ingress}"
                destination = "${var.ACLdest_ingress}"
                direction = "ingress"
                udp {
                  port_max = "${var.tcp_max_port}"
                  port_min = "${var.tcp_min_port}"
                }
            }
            ]
        }

#############      VIRTUAL SERVER - Deploy, connect, ssh and app install with bootstrap     ############


# Create VPC ssh-key in given zone. We require ssh key for privisioning VM.
resource "ibm_is_ssh_key" "iot_on_vpc_sshkey" {
  name  = "terraform-iot-on-vpc-sshkey"
  public_key = "${var.ssh_key}"
}


# This terrform file has script to deploy virtual server on VPC. 
# Required attributes:
# name: name of vsi.
# image: os image id.
# profile: machine type.
# subnet: vpc subnet id. e.x: "61a3af2e-a66e-4f36-a27e-e71cb537121d"
# vpc: deployed vpc id. e.x: ebfdb465-04a2-4668-a513-4f86fde6320f
# zone: zone in which vsi will be deployed to. Should be same as vpc zone. e.x: "eu-de-3"
# key: vpc ssh key. e.x:["636f6d70-0000-0001-0000-00000015d753"]
# user_data: upload bash file with IoT application.  
resource "ibm_is_instance" "iot_on_vpc_vm" {
  name    = "terraform-iot-on-vpc-vm"
  image   = "${var.image_template_id}"
  profile = "${var.machine_type}"
  primary_network_interface = {
    port_speed = "${var.port_speed}"
    subnet     = "${ibm_is_subnet.iot_on_vpc_subnet.id}" 
    security_groups = ["${ibm_is_vpc.iot_on_vpc.default_security_group}"]
    }
  vpc  = "${ibm_is_vpc.iot_on_vpc.id}"
  zone = "${var.availability_zone}" 
  keys = ["${ibm_is_ssh_key.iot_on_vpc_sshkey.id}"] 
  user_data = "${file("bootstrap.sh")}"
}


# Reserve a floating IP and associate it to the network interface of 
# a virtual server instance to allow public traffic to the instance.
resource "ibm_is_floating_ip" "iot_on_vpc_flooting_ip" {
  name   = "terraform-iot-on-vpc-flooting_ip"
  target = "${ibm_is_instance.iot_on_vpc_vm.primary_network_interface.0.id}"
}


