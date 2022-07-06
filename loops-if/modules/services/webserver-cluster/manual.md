# Security groups
## instances
Create a security group for the instances.  
![](media/2022-03-25-13-35-48.png)  
Name terraform-example-paul.  
Enter a description: Allow http on port 8080 to instances  

Add an inbound rule:  
![](media/2022-03-25-13-36-32.png)  
  Type: Custom TCP  
  Port Range 8080  
  Source: 0.0.0.0/0  

Delete the outbound rule  

Click create security group  

## load balancer
Create a security group for the load balancer.  
![](media/2022-03-25-13-35-48.png)  
Name terraform-alb-paul.  
Enter a description: allow http inbound and health checks outbound  
  
Add an inbound rule: 
![](media/2022-03-25-13-40-13.png)   
  Type: HTTP  
  Source: 0.0.0.0/0  


# Launch configuration for instances
Go to Launch configurations and click Create launch configuration  
![](media/2022-03-25-13-22-39.png)  

![](media/2022-03-25-13-30-51.png)  
Name: launchconfig-paul  

![](media/2022-03-25-13-31-19.png)  
Select the AMI, find and select ami-0c6ebbd55ab05f070  

![](media/2022-03-25-13-31-49.png)  
Choose instance type, find and select t2.micro from the list   

Expand Additional Configuration  
![](media/2022-03-25-15-00-07.png)  
In the user data box enter:
```
  #!/bin/bash
  echo "Hello, World!" > index.html
  nohup busybox httpd -f -p 8080 &
```

![](media/2022-03-25-13-33-42.png)  
Select the existing security group: terraform-example-paul

![](media/2022-03-25-13-34-03.png)  
Select Proceed without key-pair and select acknowledge.  

Click Create launch configuration  

# Loadbalancer
## Target groups
Go to Target Groups and click Create Target Group  
![](media/2022-03-25-13-57-55.png)  
Select target type: instances

![](media/2022-03-25-13-58-49.png)  
Target group name: terraform-asg-paul  

![](media/2022-03-25-14-07-59.png)  
Change the port to 8080  

Expand advanced health check settings  
![](media/2022-03-25-13-59-35.png)  
Set healthy threshold to 2  
Set Timeout to 3  
Set Interval to 15  

Click next  
Click Create Target Group  


## load balancer
Go to Load balancers and click create Load Balancer  
![](media/2022-03-25-13-46-32.png)  
Click create under the desired load balancer, here Application Load Balancer.  

![](media/2022-03-25-13-49-46.png)  
Name: terraform-asg-paul  

![](media/2022-03-25-13-52-35.png)  
Select all three availability zones.  

![](media/2022-03-25-13-53-33.png)  
Select the security group terraform-alb-paul  
Remove the default security group  

![](media/2022-03-25-14-04-37.png)  
Select the target group terraform-asg-paul  

Edit the listener  
![](media/2022-03-25-14-18-55.png)  

Remove the default action of Forward to  
![](media/2022-03-25-14-20-22.png)

Select the action: Fixed Response  
![](media/2022-03-25-14-21-33.png)  
Set response code to 404  
Set Response Body to: 404: page not found  

Click Save Changes  

Now click on view/edit rules  

![](media/2022-03-25-14-49-23.png)  
Click the +  

![](media/2022-03-25-14-49-45.png)  
Click + Insert Rule  

![](media/2022-03-25-14-51-00.png)  
Click add condition and select Path  
Enter the value : *  
Click the blue check mark  

Click Add Action and select Forward to  
Select the target group, terraform-asg-paul  
Click the blue check mark  

Click Save  




# Auto Scaling Group
Go to Auto Scaling Groups and click Create Auto Scaling Group  
![](media/2022-03-25-14-28-31.png)  
Name:  asg-paul

![](media/2022-03-25-14-29-26.png)  
Click Switch to Launch Configuration  

![](media/2022-03-25-14-30-09.png)  
Select the desired launch configuration, launchconfig-paul  

Click next  

![](media/2022-03-25-14-31-28.png)  
Select al three Availability Zones  

Click Next  

![](media/2022-03-25-14-32-40.png)  
Select Attach to an existing load balancer  
Select target group terraform-asg-paul under Existing load balancer target groups  


![](media/2022-03-25-14-34-32.png)  
Select ELB 

Click Next  

![](media/2022-03-25-14-36-03.png)  
Set Desired capacity to 2  
Set Minimum capacity to 2  
Set Maximum capacity to 4  

Click Next  

Click Next  

![](media/2022-03-25-14-38-32.png)  
Add a tag with Key: Name  
and Value: terraform-asg-paul  

Click Next  

Click Create Auto Scaling Group  


## schedule
Go to automatic scaling and click Create scheduled action  

![](media/2022-05-19-10-58-16.png)  
Click create  