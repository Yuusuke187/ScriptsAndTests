function Get-ExcelColumn($number)
{
    $alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
    $columnName = ""

    $letter = $alphabet[($number - 1) % $alphabet.Length]
    $multiplier = [Math]::Ceiling( [double]$number / [double]($alphabet.Length) )

    for($i = 0; $i -lt $multiplier; $i++)
    {
        $columnName += $letter
    }

    $columnName
}