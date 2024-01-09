Param(
    [Parameter(Mandatory=$false)] [string]$pat
)

Clear-Host

$orgName = Read-Host -Prompt "Please enter your Azure DevOps Organization name: "

#List all projects via org name
$ListAllProjectsURL="https://dev.azure.com/$orgName/_apis/projects?api-version=6.0"

if ($pat -eq $NULL)
{
    $pat = Read-Host -Prompt "Enter your Personal Access Token"
    Write-Host `n
}

Write-Host "Returning a list of commits..."
$base64AuthInfo= [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes(":$($pat)"))

#Get the project name
try
{
    $ListAllProjects = Invoke-RestMethod -Uri $ListAllProjectsURL -Headers @{Authorization = "Basic {0}" -f $base64AuthInfo} -Method get
}
catch
{
    Write-Error "Unable to retrieve all of the Projects. Try using a different Personal Access Token (PAT)."
}

ForEach ($ProjectName in $ListAllProjects.value.name)
{
    #Write-Host $ProjectName
    #List all repos via org name and project name and get the repo name.
    $ListAllRepoURL = "https://dev.azure.com/$orgName/$($ProjectName)/_apis/git/repositories?api-version=6.0"
    $ListAllRepo = Invoke-RestMethod -Uri $ListAllRepoURL -Headers @{Authorization = "Basic {0}" -f $base64AuthInfo} -Method get

    ForEach ($RepoName in $ListAllRepo.value.name)
    {
        #Write-Host $RepoName
        $ListAllBranchURL = "https://dev.azure.com/$orgName/$($ProjectName)/_apis/git/repositories/$($RepoName)/refs?filter=heads&api-version=6.1-preview.1"
        $ListBranchName = Invoke-RestMethod -Uri $ListAllBranchURL -Headers @{Authorization = "Basic {0}" -f $base64AuthInfo} -Method get
        #get branch name
        foreach($Branch in $ListBranchName.value){
            # $BranchName = $Branch.name.split("/",3)[-1] # Fix This
            $BranchName = $Branch.name -replace "refs/heads/"

            $currentDateBeforeString = Get-Date
            $pastDateModifier = -1

            if($currentDateBeforeString.DayOfWeek -eq "Monday")
            {
                $pastDateModifier = -3
            }

            if($currentDateBeforeString.DayOfWeek -eq "Sunday")
            {
                $pastDateModifier = -2
            }

            $currentDate = (Get-Date -format 'MM/dd/yyyy HH:mm:ss').ToString()
            # $pastDateModifier = -1
            $pastDate = (Get-Date (Get-Date).AddDays($pastDateModifier) -format 'MM/dd/yyyy HH:mm:ss').ToString()

            # List commits from the the previous business day to the current time across all repositories in one organization in Azure DevOps
            $ListCommitInfoPast = "https://dev.azure.com/$orgName/$($ProjectName)/_apis/git/repositories/$($RepoName)/commits?searchCriteria.fromDate=$pastDate&searchCriteria.toDate=$currentDate&searchCriteria.itemVersion.version=$($BranchName)&api-version=6.0"
            $ListCommitInfo = Invoke-RestMethod -Uri $ListCommitInfoPast -Headers @{Authorization = "Basic {0}" -f $base64AuthInfo} -Method get

            if($ListCommitInfo.count -ge 1)
            {
                if ($($ListCommitInfo.count) -gt 1)
                {
                    Write-Host "Project name is:"$ProjectName "    `nrepo name is:" $RepoName    `n"branch name is:" $BranchName    "and the following commits are from these users at these times: " `n
                    foreach($commit in $ListCommitInfo.value)
                    {
                        Write-Host "CommitId: `t" $commit.commitId `t" Committer: `t" $commit.committer.name `t`t" Date: `t" $commit.committer.date
                    }
                    Write-Host `n
                }
                else
                {
                    Write-Host "We only had one commit in the branch $BranchName"
                    Write-Host "Project name is:"$ProjectName "    `nrepo name is" $RepoName    `n"branch name is" $BranchName    `n"the committer is" $ListCommitInfo.value.committer.name    `n"and commit ID is" $ListCommitInfo.value.commitId `n"at the time: " $listCommitInfo.value.committer.date`n
                }
            }
        }
    }
}