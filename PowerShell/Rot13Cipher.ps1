# Install-Module -Name Pester -Force -SkipPublisherCheck
Import-Module Pester

$charArray = "abcdefghijklmnopqrstuvwxyz" -split "" `
    | Where-Object { $_ -and $_.Trim() }

# This will return a lettr from the 
# ROT13 cipher
function Set-Rot13Cipher {
    param (
        [int]$num
    )

    $index = $num % $charArray.Length
    return $charArray[$index]
}

# Write tests for the 
# Set-Rot13Cipher function
# These will only work in their
# own file.

# Describe "Set-Rot13Cipher" {
#     It "Sets 13, returns 'n'" {
#         $result = Set-Rot13Cipher(13)
#         $result | Should -Be "n"
#     }
# }

# Describe "Set-Rot13Cipher" {
#     It "Sets 1000, returns 'm'" {
#         $result = Set-Rot13Cipher(13)
#         $result | Should -Be "m"
#     }
# }