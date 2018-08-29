
#######################################################################################################
# Script: Add existing availability set VMs to newly created Azure Public Load Balancer BackendPool - Azure
# Author: Ahmed Hussein - Microsoft 
# Date: August 2018
# Version: 1.0
# References: https://docs.microsoft.com/en-us/azure/load-balancer/quickstart-create-standard-load-balancer-powershell
# GitHub: https://github.com/ahussein-CSA/Add-an-existing-availability-set-to-Azure-Loadbalancer-backendpool
#
# THIS CODE AND INFORMATION IS PROVIDED "AS IS" WITHOUT WARRANTY OF
# ANY KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO
# THE IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A
# PARTICULAR PURPOSE.
#
# IN NO EVENT SHALL MICROSOFT AND/OR ITS RESPECTIVE SUPPLIERS BE
# LIABLE FOR ANY SPECIAL, INDIRECT OR CONSEQUENTIAL DAMAGES OR ANY
# DAMAGES WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS,
# WHETHER IN AN ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS
# ACTION, ARISING OUT OF OR IN CONNECTION WITH THE USE OR PERFORMANCE
# OF THIS CODE OR INFORMATION.
#
#
########################################################################################################

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
$lbsku = 'Standard' # default  as Standard  
$publicIpsku = 'Basic' # initial as Basic  ---> No need to change this one as it relies on lbsku
$allocation='Dynamic' # initialize as Dynamic
$RequestPath='<request path>' # only needed when the port being used is HTTP

# Create a public IP address.
# check the Lb Sku - if standard it requires public IP to be standard sku and static IP

If ($lbsku -eq 'Standard')  {

    $allocation='Static'
    $publicIpsku ='Standard'


  }

$publicIp = New-AzureRmPublicIpAddress -ResourceGroupName $rgName -Name $pIPname  `
  -Location $location -AllocationMethod $allocation -sku $publicIpsku

# Create a front-end IP configuration for the website.

$feip = New-AzureRmLoadBalancerFrontendIpConfig -Name $fename -PublicIpAddress $publicIp


# Create the back-end address pool.
$bepool = New-AzureRmLoadBalancerBackendAddressPoolConfig -Name $bepoolname

If ($port -eq 'HTTP')  {
# Creates a load balancer probe on specific port for HTTP port
$probe = New-AzureRmLoadBalancerProbeConfig -Name $probename -Protocol $protocol -Port $port `
-RequestPath $RequestPath -IntervalInSeconds $intinseconds -ProbeCount $probcount
}

else {
# Creates a load balancer probe on specific port for TCP
$probe = New-AzureRmLoadBalancerProbeConfig -Name $probename -Protocol $protocol -Port $port `
-IntervalInSeconds $intinseconds -ProbeCount $probcount

}

# Creates a load balancer rule for specific port(beport,feport).
$rule = New-AzureRmLoadBalancerRuleConfig -Name $rulename -Protocol $protocol `
  -Probe $probe -FrontendPort $feport -BackendPort $beport `
  -FrontendIpConfiguration $feip -BackendAddressPool $bePool

# Creates load balancer

New-AzureRmLoadBalancer -ResourceGroupName $rgName -Name $lbname -Location $location `
  -FrontendIpConfiguration $feip -BackendAddressPool $bepool `
  -Probe $probe -LoadBalancingRule $rule -sku $lbsku





# Define the availability set.

$aset = Get-AzureRmAvailabilitySet -ResourceGroupName $rgName -AvailabilitySetName $avs

# Reference virtual machines within the availablity Set.

$vms = $aset.VirtualMachinesReferences

# Loop through the availability sets.

foreach ($vm in $vms) { 

# retrieve Virtual machine name

$name = Get-AzureRmResource -ResourceId $vm.Id | Select-Object -Expandproperty Name

# retrieve the nic interface for the virtual machine - assuming that only one nic interface exist.

$nic=(Get-AzureRmNetworkInterface | Where-Object {($_.VirtualMachine.id).Split("/")[-1] -like $name})

# assign the retrieved network interface and its IP to the backend pool of the load balancer.

$nic.IpConfigurations[0].LoadBalancerBackendAddressPools=$bepool

Set-AzureRmNetworkInterface -NetworkInterface $nic

}
