data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = var.owners
  filter {
    name   = "name"
    values = var.values
    # aws cli method:  aws ssm get-parameters-by-path --path "/aws/service/ami-amazon-linux-latest"  --profile soumitraTenant
    # https://aws.amazon.com/blogs/compute/query-for-the-latest-amazon-linux-ami-ids-using-aws-systems-manager-parameter-store/
    #/*  Go to AWS console, and find your ec2 instance you want to use:
    #    Then use the below aws cli command:
    #    aws ec2 describe-images   --image-ids ami-02fe94dee086c0c37 --profile soumitraTenant --region us-east-2  # or whatever region
    #    Use the name of the image from the output of this command and put in in values in teh data "aws_ami_ids"
    #      OR
    #        you can get it directly from AMI Location by looking at an already spun up EC2 with that image
    #        Here I get /ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-20210128,  replace the 20210128  by *, this is a must !
    #*/      Also, make sure to get correct ownere ID
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

}
