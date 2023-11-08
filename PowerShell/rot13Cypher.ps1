$charArray = "abcdefghijklmnopqrstuvwxyz" -split "" | Where-Object { $_ -and $_.Trim() }
# charArray needs to be stripped of blank values

# If a word is submitted its letters need to be replaced with letters 13 places ahead


# Circular Array
34 % $charArray.Length # This will return 8 or the eigth charcter of the alphabet

# Return the letter
$charArray[34 % $charArray.Length]

