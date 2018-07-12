# get-all-teams-with-guests
Find microsoft teams organization wide with guests included
SYNOPSIS
 
    script to find all ms teams group with guest accounts
 
    .DESCRIPTION
    
 
 
    .EXAMPLE
    no parameters needed 
 
    .Notes
    connect to exchange online + microsoft teams first, delet the # at the beginnig of the scripts 
    https://technet.microsoft.com/en-us/library/jj984289(v=exchg.160).aspx
    
   
    ---------------------------------------------------------------------------------
                                                                                 
    Script:       get-allteams-with-guest-0-2.ps1                                      
    Author:       A. Koehler; blog.it-koehler.com
    ModifyDate:   04/07/2018                                                        
    Usage:        identify all teams groups in office 365 and get guests
    Version:      0.2
                                                                                  
    ---------------------------------------------------------------------------------
#>
### start connection to exchange online and ms teams 
# Set-ExecutionPolicy RemoteSigned
# $UserCredential = Get-Credential
# $Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://outlook.office365.com/powershell-liveid/ -Credential $UserCredential -Authentication Basic -AllowRedirection
# Import-PSSession $Session
# Import-Module MicrosoftTeams
# Connect-MicrosoftTeams -Credential $UserCredential
