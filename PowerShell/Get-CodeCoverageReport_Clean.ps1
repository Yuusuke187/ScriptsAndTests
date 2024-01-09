# Produce generic NUnit tests results
# dotnet test -l:trx -- NUnit.TestOutputXml=D:\TestResults\output.trx

# Produce an XPlat report for ReportGenerator to ingest
# This will return a list of TRX files
# This is the test we want to use
dotnet test --collect:"XPlat Code Coverage"

# We need to install reportgenerator.exe first
# To install, run this from the Command Line
# dotnet tool install --global dotnet-reportgenerator-globaltool --version 5.1.22


# Set reportgenerator to use a variable
$xmlReport = ""
$targetDirectory = ""
reportgenerator.exe `
"-reports:$xmlReport" `
"-targetdir:$targetDirectory"

# =====================================
# Now here is the actual script
# We need to have Target Directory be an input variable


# Get the report in a variable
$report = dotnet test --collect:"XPlat Code Coverage"

# Get the index after Attachments point:
$ind = $report.IndexOf("Attachments:") + 1

# Get the last line of the output (it's an array)
$lastIndex = $report.Count - 1

# Return the paths of the reports
$reportPaths = $report[$ind..$lastIndex]

# For reach of these report paths, we need to run report generator


foreach($reportPath in $reportPaths) 
{
    # Trim each path
    $reportPath = $reportPath.Trim()

    # Generate reports flag
    $reportsFlag = "-reports:" + $reportPath

    # The Target Directory should be the last foldername before
    # TestResults
    $trimmedReportPath = $reportPath.Split("\/")
    $targetDir = $trimmedReportPath[$trimmedReportPath.IndexOf("TestResults") - 1]


    reportgenerator.exe `
    $reportsFlag `
    "-targetdir:DeviceConfiguration_Report"

    reportgenerator.exe `
    $reportsFlag `
    "-targetdir:$targe"
}
