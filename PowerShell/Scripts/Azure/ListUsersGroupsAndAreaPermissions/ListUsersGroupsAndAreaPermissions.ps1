﻿Param
(
    [string]$PAT,
    [string]$Organization,
    [string]$ProjectName,
    [string]$mailAddress,
    [string]$Connstr
)

Function get-Identifier ($children,[ref]$AllAreaPaths)
{
    ForEach ( $ac in $children )
    {         
        $AreaNodes.Add((add-AreaMember -member $ac))
        $ac | get-Identifier -children $ac.children -AreaNodes ([ref]$AllAreaPaths)
    }
}

Function add-AreaMember ($member)
{
    $newMember = New-Object PSObject
    $newMember | Add-Member -MemberType NoteProperty -Name "Identifier" -Value $member.identifier
    $newMember | Add-Member -MemberType NoteProperty -Name "Path" -Value $member.path.Replace("\Area",'').Substring(1)   
    return $newMember
}

$SQLQuery = "TRUNCATE TABLE AreaPermissions"
Invoke-Sqlcmd -query $SQLQuery -ConnectionString $Connstr

$SecurityNameSpaceIdCSS = "83e28ad4-2d72-4ceb-97b0-c7726d5502c3"

echo $PAT | az devops login --org $Organization

az devops configure --defaults organization=$Organization

#select user on organization
$allUsers = az devops user list --org $Organization | ConvertFrom-Json
$allUsers = $allUsers.members 
$allUsers = $allusers.user | where-object {$_.mailAddress -eq $mailAddress}

#select project
$allProjects = az devops project list --org $Organization --top 500 | ConvertFrom-Json
$allProjects = $allProjects.value | Where name -EQ $ProjectName
$Domain = "vstfs:///Classification/TeamProject/$($allProjects.id)"

#Get Root Area Path 
$AzureDevOpsAuthenicationHeader = @{Authorization = 'Basic ' + [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(":$($PAT)")) }
$uriProjectRootArea = $Organization + "/$($ProjectName)/_apis/wit/classificationnodes?api-version=6.0"
$ProjectRootAreaResult = Invoke-RestMethod -Uri $uriProjectRootArea -Method get -Headers $AzureDevOpsAuthenicationHeader
$ProjectRootAreaResult = $ProjectRootAreaResult.value | Where structureType -EQ "area"
$areaRootToken = "vstfs:///Classification/Node/$($ProjectRootAreaResult.identifier)*"

#Get All Area Paths
$uriAreaPath = $Organization + "/$($ProjectName)/_apis/wit/classificationnodes/Areas?`$depth=5&api-version=4.1"
$AreaPathResult = Invoke-RestMethod -Uri $uriAreaPath -Method get -Headers $AzureDevOpsAuthenicationHeader
$AreaNodes = New-Object 'System.Collections.Generic.List[psobject]'
$AreaNodes.Add((add-AreaMember -member $AreaPathResult))
$AreaPathResult | get-Identifier -children $AreaPathResult.children -AreaNodes ([ref]$AreaNodes)

#Get all group that respective user belongs
$activeUserGroups = az devops security group membership list --id $allUsers.principalName --org $Organization --relationship memberof | ConvertFrom-Json
[array]$groups = ($activeUserGroups | Get-Member -MemberType NoteProperty).Name

Foreach ($aug in $groups)
{       
    if ($Domain -eq $activeUserGroups.$aug.domain)
    {
        #Get All Tokens from respective group and filter respective project
        $allAreasTokens = az devops security permission list --id $SecurityNameSpaceIdCSS --subject $activeUserGroups.$aug.descriptor | ConvertFrom-Json
        $allAreasTokens = $allAreasTokens | where-object {$_.token -like $areaRootToken}
        Foreach ($aat in $allAreasTokens)
        {
            $AreaPathName = $AreaNodes | Where-Object {$_.identifier -EQ $aat.token.Substring($aat.token.lastIndexOf('/') + 1)}
            
            #Get AreaPath Commands and Permissions from respective group and token
            $AreaCommands = az devops security permission show --id $SecurityNameSpaceIdCSS --subject $activeUserGroups.$aug.descriptor --token $aat.token --org $Organization | ConvertFrom-Json
            $AreaPermissions = ($AreaCommands[0].acesDictionary | Get-Member -MemberType NoteProperty).Name
            foreach($ap in $AreaCommands.acesDictionary.$AreaPermissions.resolvedPermissions)
            {               
                $SQLQuery = "INSERT INTO AreaPermissions (
                            TeamProjectName,
                            AreaPathName,
                            SecurityNameSpace,
                            UserPrincipalName,
                            UserDisplayName,
                            GroupDisplayName,
                            GroupAccountName,
                            AreaCommandName,
                            AreaCommandInternalName,
                            AreaCommandPermission)
                            VALUES(
                            '$($allProjects.name)',
                            '$($AreaPathName.path)',
                            'CSS',
                            '$($allUsers.principalName)',
                            '$($allUsers.displayName)',
                            '$($activeUserGroups.$aug.displayName)',
                            '$($activeUserGroups.$aug.principalName)',
                            '$($ap.displayName.Replace("'",''))',
                            '$($ap.name)',
                            '$($ap.effectivePermission)'
                            )"
                Invoke-Sqlcmd -query $SQLQuery -ConnectionString $Connstr
            }
        }
    }
}
