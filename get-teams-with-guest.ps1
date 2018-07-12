<#
    .SYNOPSIS
 
    script to find all ms teams group with guest accounts
 
    .DESCRIPTION
    
 
 
    .EXAMPLE
    no parameters needed 
 
    .Notes
    connect to exchange online first, delet the # at the beginnig of the scripts 
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
#####################################################################################################

#get all o365 groups from exchange online
$o365groups = Get-UnifiedGroup -ResultSize unlimited
#generate array
$externalteams = @()
$output = @()
foreach ($o365group in $o365groups) {
  try {
    $teamschannels = Get-TeamChannel -GroupId $o365group.ExternalDirectoryObjectId 
    $output += [pscustomobject]@{GroupId = $o365group.ExternalDirectoryObjectId; GroupName = $o365group.DisplayName; TeamsEnabled = $true} 
  } catch {
    $ErrorCode = $_.Exception.ErrorCode
    switch ($ErrorCode) {
      "404" {
        $output += [pscustomobject]@{GroupId = $o365group.ExternalDirectoryObjectId; GroupName = $o365group.DisplayName; TeamsEnabled = $false}
        break;
      }
      "403" {
        $output += [pscustomobject]@{GroupId = $o365group.ExternalDirectoryObjectId; GroupName = $o365group.DisplayName; TeamsEnabled = $true} 
        break;
      }
      default {
        Write-Error ("Unknown ErrorCode trying to 'Get-TeamChannel -GroupId {0}' :: {1}" -f $o365group, $ErrorCode)
      }
    }
  }
} 

#search for teamenabled groups
$teams = $output | Where-Object{$_.TeamsEnabled -eq $true}
#count teams
$number = $teams.Count
#check if there are teams enabled groups available
if($number -eq "0"){
  Write-host "there are no teams in your organization" -ForegroundColor yellow
 }
else{
  #go through every team and search for external users
  foreach ($team in $teams){
    #get groupid of the team 
    $groupid = ($team.groupid)
    #search external users 
    $users = (Get-UnifiedGroup -Identity $groupid | Get-UnifiedGroupLinks -LinkType Members | Where-Object {$_.Name -like "*#EXT#*"})
    #count external users
    $extcount = ($users.count)
    #go through every team an put teamname and teammembers in custom object
    foreach ($extuser in $users){
      #get displayname from team
      $teamext = (($o365groups | Where-Object {$_.ExternalDirectoryObjectId -eq "$groupid"}).DisplayName).ToString()
      $teamextcreatedate = (($o365groups | Where-Object {$_.ExternalDirectoryObjectId -eq "$groupid"}).WhenCreated).ToString()
      #get the external users 
      $ext = $extuser.Name
      #create custom object
      $externalteams += [pscustomobject]@{
        ExtUser   = $ext
        TeamName  = $teamext
        TeamsCreationDate = $teamextcreatedate
        GroupID   = $groupid
       } 
      }
     }
  #check if there are some teams with external users or not 
  if ($extcount -eq "0"){
    Write-host "there are no external user added to any team in your organization" -ForegroundColor yellow
    
    }
  else{
    #show custom object in powershell
    $externalteams | Out-GridView -Title "external members in Teams"
    <#
        $Header = @"
        <style>
        TABLE {border-width: 1px; border-style: solid; border-color: black; border-collapse: collapse;}
        TD {border-width: 1px; padding: 3px; border-style: solid; border-color: black;}
        </style>
        "@
        $externalteams | ConvertTo-Html -Property ExtUser,TeamName,GroupID -Head $Header | Out-File -FilePath .\msteam-guests.html
        Invoke-Expression ".\msteam-guests.html"
    #>
   
  }
}
