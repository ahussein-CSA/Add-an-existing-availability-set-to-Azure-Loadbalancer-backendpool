# Add an existing availability set to Azure Loadbalancer backendpool - TCP/HTTP
Created by Ahmed Hussein

Current repository includes two powershell scripts

1. newloadbalancer_existingavailabilityset.ps1
    
    1.1 Standard SKU
    1.2 Basic SKU
    
2. existingloadbalancer_existingavailabilityset.ps1

# What does the powershell script "newloadbalancer_existingavailabilityset.ps1" do ? 

Script one provides the following:

1. Create a new Public IP:  
      
      Please note: if you are going to use Basic SKU load balancer you can use dynamic public IP, however standard Sku public load balancer requires a standard sku static public IP.
      
2. Creat a front-end IP configuration using the created public IP 

3. Create the back-end address pool.

4. Create a load balancer probe on specific port.
    
    Please note: If you are going to use standard SKU load balancer on TCP port then -RequestPath parameter should be removed. 

5. Create a load balancer rule for provided port

6. Create the public load balancer
   
   Please note: Standard SKU loadbalancer is not free. no Nat rules are being implemented - Could be added to future update, however if you are looking for details on this please go to : https://docs.microsoft.com/en-us/azure/load-balancer/quickstart-create-standard-load-balancer-powershell - This script are using some of the statements being used in the document above.
   
7. Loop through existing provided availability set - assign its VMs as part of the backendpool for the newly created load balancer.

    Please note: it will assign only the first private ip as the target ip for the VM.


# Variables within the script

