# Security group
In the console go to Security Groups  
![](media/2022-03-24-13-47-24.png)
Click Create security group  

![](media/2022-03-24-13-49-37.png)
Fill out a name.  
Manually you need the add a description, if created by terraform a default description is added (Managed by Terraform).  
Select the VPC you want the security group attached to, here it's the default.  

![](media/2022-03-24-13-50-47.png)
Under Inbound rules, click Add rule  

![](media/2022-03-24-13-52-27.png)
Create rule as above  

![](media/2022-03-24-13-53-11.png)
Click Create security group  

# EC2 instance
In the console go to EC2  

![](media/2022-03-24-13-35-38.png)
Click Launch Instances  

![](media/2022-03-24-13-37-18.png)
Select the AMI you want to run, here ami-0c6ebbd55ab05f070.  

![](media/2022-03-24-13-38-24.png)
Select your instance type, here t2.micro.  

![](media/2022-03-24-13-40-09.png)
Click 'Next: Configure Instance Details'  

On the next screen you can edit VPC and subnets etc, for now the defaults are fine.  

Under advanced details  
![](media/2022-03-24-13-43-51.png)
Enter the user_data in the box
```
  #!/bin/bash
  echo "Hello, World!" > index.html
  nohup busybox httpd -f -p 8080 &
```
Note: user-data is default only run at first boot.
If you want it to run every boot, follow [this doc](https://aws.amazon.com/premiumsupport/knowledge-center/execute-user-data-ec2/)  

Click Next: Add storage  
For now, nothing to do  
Click Next: Add Tags  

![](media/2022-03-24-14-01-07.png)
Click Add Tag  
Give it a Key (Name) and a Value (terraform-example-paul)  

Click Next: Configure Security Group  

![](media/2022-03-24-14-03-16.png)
Because the security group is already created, select an existing security group  
Select the security group you want associated with the instance, here the one with the name terraform-example-paul.  


Click Review and Launch  

![](media/2022-03-24-14-05-46.png)
For now, ignore this warning, if necessary, add the port to the security group.
Click continue.  

Review the instance details.  
Click Launch.  

![](media/2022-03-24-14-13-03.png)
For now, select Proceed without a key pair and check Acknowledge.  
Click Launch Instances  
