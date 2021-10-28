<#
██╗    ██╗██╗  ██╗███████╗███████╗███████╗ ██████╗ ██████╗ ██████╗ ██████╗ 
██║    ██║██║ ██╔╝██╔════╝██╔════╝██╔════╝██╔════╝██╔════╝ ██╔══██╗██╔══██╗
██║ █╗ ██║█████╔╝ ███████╗███████╗█████╗  ██║     ██║  ███╗██████╔╝██████╔╝
██║███╗██║██╔═██╗ ╚════██║╚════██║██╔══╝  ██║     ██║   ██║██╔══██╗██╔═══╝ 
╚███╔███╔╝██║  ██╗███████║███████║███████╗╚██████╗╚██████╔╝██║  ██║██║     
 ╚══╝╚══╝ ╚═╝  ╚═╝╚══════╝╚══════╝╚══════╝ ╚═════╝ ╚═════╝ ╚═╝  ╚═╝╚═╝     
                                                            Version 1.0

.SYNOPSIS
wkssecgrp.ps1 - Script to check that a specified type of machine is in a specific security group

.DESCRIPTION
Script to check that a specified type of machine is in a specific security group, to add them as needed and to make a report by email.


.INPUTS
set the "filter_computer_name" and "security_group_name" in the "Configuration\config.xml" file

.OUTPUTS
Email reporting

.CONFIGURATION
set the "Configuration\config.xml" file

.LINK
N/A

.EXAMPLE
N/A

.NOTES
Written by: Christophe Pelichet (cpelichet@protonmail.com)

Find me on: 

* LinkedIn:     https://linkedin.com/in/christophepelichet
* Github:       https://github.com/ChristophePelichet

Change Log 
V1.00 - 28/10/2020 - Initial version
#>


########################################################
######################## Path ##########################
########################################################

$my_script_path             = split-path -parent $MyInvocation.MyCommand.Definition
$my_function_path           = $my_script_path + "\Functions"
$my_configuration_path      = $my_script_path + "\Configuration\config.xml"

#######################################################
###################### Modules ########################
#######################################################

# Load Configuration 
$load_my_configuration = $my_function_path + "\" + "get_LoadConfig.ps1"
    . $load_my_configuration
    get_LoadConfig -path $my_configuration_path

#######################################################
###################### Variables ######################
#######################################################

# Debug mode
$debug = $appSettings["debug"]

# Computers filet and list
$filter_computer_name = $appSettings["filter_computer_name"]

# Security group name 
$security_group_name = $appSettings["security_group_name"]

# Email 
$email_report	= $appSettings["email_report"]
$email_subject	= $appSettings["email_subject"]
$email_from		= $appSettings["email_from"]
$email_to		= $appSettings["email_to"]
$email_server	= $appSettings["email_server"]
$email_port 	= $appSettings["email_port"]

# Array
$computer_added_num = @()

######################################################
#################### Functions #######################
######################################################

function send_report_email() {

# Debug 
if ($debug -eq '1') {  write-host `n"## Information : Sending report by email" }

# Convert Array to string
$email_body_computer_added = $computer_added_num | Out-String
if (!$email_body_computer_added) { $email_body_computer_added = "No Computer Added"}

# Count computer scanned 
$computers_scanned_num = $computers_list.count

# Count computer added
$computers_added_num = $computer_added_num.count

# Create email subject
$email_subject = "[$email_subject] - " + $security_group_name


# Create email body
$email_body = "

Information : 
================= 
Computer Filter    ->   $filter_computer_name
Number of computers scanned   ->   $computers_scanned_num
Number of computers added     ->   $computers_added_num
Security Group     ->   $security_group_name


The following machines have been added to the security group : $security_group_name 
================================================================================= 

$email_body_computer_added
"


# Send report
Send-MailMessage -Subject $email_subject -From $email_from -To $email_to -Body $email_body -SmtpServer $email_server -Port $email_port

}

######################################################
################### Start Scripts ####################
######################################################

# Debug
If ($debug -eq '1') { write-host `n"################" `n"# Start Script #" `n"################" ; write-host `n"## Information : Debug Mode  Enabled" }

# Get computers list 
$computers_list = Get-ADComputer -Filter { Name -like $filter_computer_name } | Select-Object Name

# Debug
if ($debug -eq '1') {  write-host `n"## Information : Start Computers Loop" }

# Start loop
foreach ($computer in $computers_list) {

    # Get real computer name
    $computer_name = $computer.Name
    if ($debug -eq '1') {  write-host `n"## Command : Processing :" $computer_name }    
    
    # Get computer security groups
    $computer_group_member = Get-ADPrincipalGroupMembership -Identity $computer_name$ | Select-Object name

    # Set verification variable
    $computer_in_the_group= 0
    
    # Processing computer group member
    foreach ( $cgm in $computer_group_member){
        if ($cgm.name -match $security_group_name){
            $computer_in_the_group = "1"
            break
        }
    }

    # Add computer in the group if is not there
    if ($computer_in_the_group -ne "1") {
        $computer_added_num = $computer_added_num + $computer_name
        Add-ADGroupMember "$security_group_name" -Members "$computer_name$"
    }
}

## Reporting
if ( $email_report -eq "1") {
    send_report_email
}


#######################################################
#################### End Scripts ######################
#######################################################

## Debug
If ($debug -eq '1') { write-host `n"################" `n"# End Script #" `n"################" ; write-host `n"## Information : Debug Mode  Enabled" }