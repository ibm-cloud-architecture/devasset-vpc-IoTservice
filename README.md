## Deploy IoT Application in an IBM Cloud VPC using Terraform

### Architecture

This asset consists of a VPC, subnet, a virtual server with an IOT application installed and the IBM Cloud IOT service.

<kbd>![Serviced-scenario](./imgs/architecture.png)</kbd>

### Prerequisites

- Account must be enabled to access VPC Infrastructure.

- Prior to runing the terraform, you should set up the IoT Platform components. You will need to create the service, register the device and application, install the IOT starter applicaion on an android device that can communicate with the IoT platform service via the internet and create the Application API key and token. See the steps below.

- Complete the [IBM Cloud Terraform tutorial](https://cloud.ibm.com/docs/ibm-cloud-provider-for-terraform?topic=ibm-cloud-provider-for-terraform-getting-started) your desktop environment will be ready to run this example

- Use the Dockerfile from the [IBM Cloud Terraform provider repository](https://github.com/IBM-Cloud/terraform-provider-ibm-docker).

### Steps to deploy this asset

1. **Build** IBM Cloud terraform docker container using the steps in the Tutorial noted above.

   - docker build -t="terraform-vpc-ibm-docker" . --no-cache
   - docker run -it terraform-vpc-ibm-docker /bin/bash

<!-- 2. Prepare to deploy

   - Log into the Docker container.
   - Clone this repository.
     \$ git clone https://github.com/ibm-cloud-architecture/refasset-public-IoT-VPC -->

2. **Deploy** VPC and IoT application

   - Change directory to the folder containing the terraform - [./infrastructure-code](./infrastructure-code).
   - Review the terraform files (main and variables) in that folder.
   - Edit the variable.tf and add your values for the variables.
   - Run Terraform (init, plan, apply).
   - Refer to the [tutorial](https://www.ibm.com/cloud/garage/architectures/public-cloud/public-cloud-infrastructure) for instructions.
   - Set up the IoT service and mobile application using steps in  the [IoT guide](./IoT/IoTguide.md)

3. **Test** by installing and using  the mobile application on your device as noted in the [IoT guide](./IoT/IoTguide.md)

4. **Enjoy!**
