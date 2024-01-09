<#
.Synopsis
   Migrates work items from old tenants to new ones - In this case, TFS to ADO
.DESCRIPTION
   The purpose of this tool is to move work orders from one specific organization in a TFS domain to a different organization in an ADO domain
.EXAMPLE
   Move-TicketsToADO.ps1
.EXAMPLE
   ----
.INPUTS
   None, as of now
.OUTPUTS
   None, as of now
.NOTES
   None, as of now
.COMPONENT
   Currently a part of DevSecOps
.ROLE
   DevOps
.FUNCTIONALITY
   This is a tool migrating Work Items
#>

# Add User input
[CmdletBinding()]
Param(
    [Parameter( HelpMessage="Input for the token e-mail address",
                Mandatory=$false)]
	[AllowNull()]
    [AllowEmptyString()]
    [string]$user,

    [Parameter( HelpMessage="Flag for the path to the output folder",
                Mandatory=$false)]
    [AllowNull()]
    [AllowEmptyString()]
    [string]$FileFolderPath,

    [Parameter( HelpMessage="Flag for the Timestamp",
                Mandatory=$false)]
    [AllowNull()]
    [AllowEmptyString()]
    [string]$Timestamp
)

# Prompt for user input
if ($tfsUser -eq $null)
{
    $tfsUser = Read-Host "Please enter the e-mail address associated with the TFS token:"
}

if ($tfsToken -eq $null)
{
    $tfsToken = Read-Host "Please input the TFS token:"
}

if ($adoUser -eq $null)
{
    $adoUser = Read-Host "Please enter the e-mail address associated wtih the ADO token - Enter nothing if it is the same as the TFS one: "
}

if ($adoToken -eq "")
{
    $adoUser = $tfsUser
}

if ($adoToken -eq $null)
{
    $adoToken = Read-Host "Please input the ADO token: "
}


# Getting the PAT credentials for TFS

$tfsBase64AuthInfo = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes((“{0}:{1}” -f $tfsUser, $tfsToken)))
$tfsHeader = @{
"Authorization" = (“Basic {0}” -f $tfsBase64AuthInfo)
"Content-Type" = 'application/json'
}

# Getting the PAT credentials for ADO
$adoBase64AuthInfo = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes((“{0}:{1}” -f $adoUser, $adoToken)))
$adoHeader = @{
"Authorization" = (“Basic {0}” -f $adoBase64AuthInfo)
"Content-Type" = 'application/json'
}


# Get a list of Work Items from TFS
# This may require WIQL queries
$sourceURI = Read-Host "Please input the source URI: "
$targetURI = Read-Host "Please input the target URI: "


# Extension to get a list of Work Item IDs - Query by WIQL
$wiqlURIExtension = "_apis/wit/wiql?api-version=5.1"
$fullURI = $sourceURI + $wiqlURIExtension
$adoWIQLURI = $targetURI + $wiqlURIExtension

$queryBody = @"
{
    "query": "SELECT [Id] from WorkItems WHERE [Area Path] = * AND [State] In ('Proposed', 'Active')"
}
"@

$listOfWorkItemIds = (Invoke-RestMethod -Uri $fullURI -Headers $tfsHeader -Body $queryBody -Method POST).workItems.id
$singleWorkItemExtension = "_apis/wit/workitems/<workItemId>?api-version=5.1"




# Create a base Post Body for ADO additions
$baseTargetWorkItemBody = @(
 @{
 op ='add'
 path ='/fields/System.Title'
 from ='null'
 value ='<Title>'
 }
 @{
 op ='add'
 path ='/fields/System.State'
 from ='null'
 value ='<State>'
 }
 @{
 op ='add'
 path ='/fields/System.Reason'
 from ='null'
 value ='<Reason>'
 }
 @{
 op ='add'
 path ='/fields/System.Description'
 from ='null'
 value ='<Description>'
 }
 @{
 op ='add'
 path ='/fields/System.AssignedTo'
 from ='null'
 value ='<AssignedTo>'
 }
)

[System.Collections.ArrayList]$baseTargetWorkItemBodyArray = $baseTargetWorkItemBody



# Get the content of each ID
foreach($workItemId in $listOfWorkItemIds)
{
    Write-Output "Constructing a URL for $workItemId"
    # Export the full content of the Work Item to ADO to a variable but first, replace the Id in the extension
    $fullURI = $sourceURI + $singleWorkItemExtension.Replace("<workItemId>", $workItemId)
    Write-Output "Retrieving a single Work Item"
    $singleWorkItem = Invoke-RestMethod `
        -Uri $fullURI `
        -Headers $tfsHeader `
        -Method GET

    # Check the Target ADO for the title of the Work Item from TFS
    $matchingTitle = $singleWorkItem.fields.'System.Title'
    if ($matchingTitle.Contains("'"))
    {
        $matchingTitle = $matchingTitle.Replace("'", "''")
    }

    $adoQueryBody = @"
{
    "query": "Select [System.Id] From WorkItems Where [System.Title] CONTAINS '$matchingTitle'"
}
"@
    Write-Output "Checking to see if the Title already exists in Azure Dev Ops"
    $previousTitleInstances = Invoke-RestMethod -Uri $adoWIQLURI -Headers $adoHeader -Method POST -Body $adoQueryBody -ContentType "application/json"
    if (($previousTitleInstances.workItems.Count) -gt 0)
    {
        # return
        # Might use continue
        continue
    }

    # Extract the Work Item Type
    Write-Output "Buidling the URI to post new Work Items to Azure DevOps"
    $workItemType = $singleWorkItem.fields.'System.WorkItemType'
    


    $postToTargetURI = $targetURI + "_apis/wit/workItems/$" + $workItemType + "?api-version=5.1"

    $newTargetWorkItemBodyArray = $baseTargetWorkItemBodyArray.Clone()

    # Write-Output "Returning the current content of the target body array"
    # $newTargetWorkItemBodyArray

    Write-Output "Creating a target Work Item from $workItemId"

    if ($workItemType -eq "Product Requirement")
    {
        
        $newTargetWorkItemBodyArray.Add(@{
 op ='add'
 path ='/fields/Microsoft.VSTS.CMMI.RequirementType'
 from ='null'
 value =$singleWorkItem.fields.'Microsoft.VSTS.CMMI.RequirementType'
}) | Out-Null

        $newTargetWorkItemBodyArray.Add(@{
 op ='add'
 path ='/fields/Custom.RequirementClassification'
 from ='null'
 value =$singleWorkItem.fields.'Microsoft.VSTS.CMMI.RequirementType'
}) | Out-Null

        $newTargetWorkItemBodyArray.Add(@{
 op ='add'
 path ='/fields/Microsoft.VSTS.TCM.ReproSteps'
 from ='null'
 value =$singleWorkItem.fields.'Microsoft.VSTS.TCM.ReproSteps'
}) | Out-Null
    }

    if ($workItemType -eq "Software Requirement")
    {
        $newTargetWorkItemBodyArray.Add(@{
 op ='add'
 path ='/fields/Custom.RequirementClassification'
 from ='null'
 value =$singleWorkItem.fields.'Microsoft.VSTS.CMMI.RequirementType'
}) | Out-Null

    if ($workItemType -eq "Task")
    {
        $workItemType = "User Story"

        $newTargetWorkItemBodyArray.Add(@{
 op ='add'
 path ='/fields/Custom.InitialVersion'
 from ='null'
 value ='1.0.0'
}) | Out-Null

        $newTargetWorkItemBodyArray.Add(@{
 op ='add'
 path ='/fields/Custom.WorkItemStatus'
 from ='null'
 value ='Current'
}) | Out-Null
    }


    $convertedTargetJsonBody = $newTargetWorkItemBodyArray | ConvertTo-Json
    $convertedTargetJsonBody = $convertedTargetJsonBody.Replace('"null"', 'null')

    # $convertedTargetJsonBody = $convertedTargetJsonBody.Replace('<Title>', $singleWorkItem.fields.'System.Title')
    $convertedTargetJsonBody = $convertedTargetJsonBody.Replace('\u003cTitle\u003e', $singleWorkItem.fields.'System.Title')

    # $convertedTargetJsonBody = $convertedTargetJsonBody.Replace('\u003cState\u003e', $singleWorkItem.fields.'System.State')
    $convertedTargetJsonBody = $convertedTargetJsonBody.Replace('\u003cState\u003e', "Proposed")

    $convertedTargetJsonBody = $convertedTargetJsonBody.Replace('\u003cReason\u003e', $singleWorkItem.fields.'System.Reason')
    $convertedTargetJsonBody = $convertedTargetJsonBody.Replace('\u003cDescription\u003e', $singleWorkItem.fields.'System.Description')
    $convertedTargetJsonBody = $convertedTargetJsonBody.Replace('\u003cRequirementType\u003e', $singleWorkItem.fields.'Microsoft.VSTS.CMMI.RequirementType')
    $convertedTargetJsonBody = $convertedTargetJsonBody.Replace('\u003cRequirementClassification\u003e', $singleWorkItem.fields.'Custom.RequirementClassification')
    $convertedTargetJsonBody = $convertedTargetJsonBody.Replace('\u003cWorkItemStatus\u003e', $singleWorkItem.fields.'Custom.WorkItemStatus')
    $convertedTargetJsonBody = $convertedTargetJsonBody.Replace('\u003cAssignedTo\u003e', $singleWorkItem.fields.'System.AssignedTo'.displayName)


    Write-Output "The features for the Target Work Order have been defined. "

    Write-Output "Returning the state of the Body to be Posted:"
    $convertedTargetJsonBody

    Write-Output "Migrating the Work Order $workItemId to Azure DevOps..."
    # $convertedTargetJsonBody
    $newTargetWorkItem = Invoke-RestMethod `
        -Uri $postToTargetURI `
        -Headers $adoHeader `
        -Method POST `
        -Body $convertedTargetJsonBody `
        -ContentType "application/json-patch+json"

    $newTargetWorkItemBodyArray = @()
    $newTargetWorkItemId = $newTargetWorkItem.id
    Write-Output "Migration Completed. $workItemId on TFS has been copied to $newTargetWorkItemId on Azure DevOps."

    if($singleWorkItem.fields.'System.State' -eq "Active")
    {
        # Use the REST API to update the state of the target

    }
}

# Update the state of each work item
foreach($workItemId in $listOfWorkItemIds)
{
    
}


# Get the full content of 2158
function Get-WorkItemContent()
{
    # Input: The ID for the Work Item
}

function New-WorkItem()
{
    # The Content-Type field in the post needs to be application/json-patch

    # Requirement Status in TFS needs to become Work Item Status in ADO
}


function switch-WorkItemStatus()
{
    # Get the work order

}

