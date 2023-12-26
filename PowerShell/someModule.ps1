# We need to figure out how to save this as a module
# We can call New-FolderAndChangeDirectory mkdirg or 
# something.

function New-FolderAndChangeDirectory {
    param(
        [string]$FolderName
    )
    $NewPath = Join-Path `
        -Path $(Get-Location).Path `
        -ChildPath $FolderName

    mkdir $NewPath
    return $NewPath
}

function mkdirg {
    param(
        [string]$FolderName
    )
    $NewPath = Join-Path `
        -Path $(Get-Location).Path `
        -ChildPath $FolderName

    mkdir $NewPath
    return $NewPath
}

