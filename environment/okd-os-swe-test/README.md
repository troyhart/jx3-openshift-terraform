# Considerations for the VPC

### NAT Gateways ###
We are currently using the **terraform-aws-modules/vpc/aws** to build out this VPC.  By default **single_nat_gateway** is set to true.  This will save cost but also will create a single point of failure if the availabililty zone goes down that the NAT gateway runs in.  Any cluster beyond a POC cluster should have **single_nat_gateway = false** set for HA reasons.

### VPC Endpoints ###
If there is a ton of connectivity from the VPC to S3 a Endpoint should be used.  OpenShift 4 cloudformation scripts include an S3 endpoint by default but I'm not sure that is necessary if S3 isn't used heavily.  Not including an S3 endpoint for now.