 
#########################################################################################

 Script One: Add existing availability set VMs to newly created Azure Public Load Balancer BackendPool - Azure

 Author: Ahmed Hussein - Microsoft 
 
 Date: August 2018
 
 Version: 1.0
 
 [References](https://docs.microsoft.com/en-us/azure/load-balancer/quickstart-create-standard-load-balancer-powershell)
 

 THIS CODE AND INFORMATION IS PROVIDED "AS IS" WITHOUT WARRANTY OF
 ANY KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO
 THE IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A
 PARTICULAR PURPOSE.

 IN NO EVENT SHALL MICROSOFT AND/OR ITS RESPECTIVE SUPPLIERS BE
 LIABLE FOR ANY SPECIAL, INDIRECT OR CONSEQUENTIAL DAMAGES OR ANY
 DAMAGES WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS,
 WHETHER IN AN ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS
 ACTION, ARISING OUT OF OR IN CONNECTION WITH THE USE OR PERFORMANCE
 OF THIS CODE OR INFORMATION.


#########################################################################################


### What does the powershell script "newloadbalancer_existingavailabilityset_Simple.ps1" do ? 

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

    Please note: The script assumes that the VM has only one Nic interface , so it will assign only the private ip as the target ip for the VM. Furture updates will loop through all the nics and assign the selected ip.


### Variables within script one

```

$rgName ='<name of the existing resource group>'
$avs = '<Name of the existing availability set>'
$location ='<Location where the LB will be deployed - must exist same region where the availability set is>'
$pIPname ='<Name of the public IP>'
$fename = '<Name of the FrontEndPool>'
$bepoolname ='<name of the BackendPool>'
$probename = '<Name of the HealthProbe>'
$rulename = '<Name of the rule>'
$lbname = '<Name of the load balancer>'
$protocol = '<TCP/HTTP>'
$port ='<port>'
$feport = '<FrontEnd port>'
$beport = '<Backend port>'
$intinseconds = '<intervals in Seconds>'
$probcount ='<unhealthy probes>'
$lbsku = 'Basic' # initialize  as Basic  
$publicIpsku = 'Basic' # initial as Basic  ---> No need to change this one as it relies on lbsku
$allocation='Dynamic' # initialize as Dynamic



```

