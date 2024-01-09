# Create a blank two dimensional array
$rows = 3
$columns = 3

$sudokuGrid = New-Object 'object[,]' $rows, $columns

# Generate random numbers from 1 to 9
function ranNum()  
{
    $randomNumber = Get-Random -Minimum 1 -Maximum 9
    return $randomNumber
}

# Create a single 3x3 Sudoku cell
# Populate it with random numbers
function New-SudokuCell()
{
    # Create a 3x3 grid
    $sudokuCell = New-Object 'object[,]' 3, 3

    for($i = 0; $i -lt $rows; $i++)
    {
        for($j = 0; $j -lt $columns; $j++)
        {
            # Sudoku can only have numbers between 0 and 9
            # Write-Debug $i
            # Write-Debug $j
            $sudokuCell[$i, $j] = (ranNum)
        }
    }

    return $sudokuCell
}

function New-SudokuCellKai()
{
    $sudokuCell = @(
        @( (ranNum), (ranNum), (ranNum) ),
        @( (ranNum), (ranNum), (ranNum) ),
        @( (ranNum), (ranNum), (ranNum) )
    )

    $sudokuCell
}

function New-BlankSudokuCell()
{
    $sudokuCell = @(
        @( 0, 0, 0 ),
        @( 0, 0, 0 ),
        @( 0, 0, 0 )
    )

    $sudokuCell
}

function New-BlankSudokuMatrix()
{
    $sudokuCell = @(
        @( 0, 0, 0,  0, 0, 0,  0, 0, 0 ),
        @( 0, 0, 0,  0, 0, 0,  0, 0, 0 ),
        @( 0, 0, 0,  0, 0, 0,  0, 0, 0 ),
        @( 0, 0, 0,  0, 0, 0,  0, 0, 0 ),
        @( 0, 0, 0,  0, 0, 0,  0, 0, 0 ),
        @( 0, 0, 0,  0, 0, 0,  0, 0, 0 ),
        @( 0, 0, 0,  0, 0, 0,  0, 0, 0 ),
        @( 0, 0, 0,  0, 0, 0,  0, 0, 0 ),
        @( 0, 0, 0,  0, 0, 0,  0, 0, 0 )
    )

    $sudokuCell
}

function New-SudokuCellValid()
{
    [System.Collections.ArrayList]$numbersToUse = @(1,2,3,4,5,6,7,8,9)

    $sudokuCell = New-BlankSudokuCell

    for($i = 0; $i -lt ($sudokuCell.Length); $i++)
    {
        for($j = 0; $j -lt ($sudokuCell[0].Count); $j++)
        {
            $randomNum = $numbersToUse | Get-Random
            $sudokuCell[$i][$j] = $randomNum
            $numbersToUse.Remove($randomNum)
        }
    }

    $sudokuCell
}



# Check to see if no number in a single 3x3 Sudoku cell
# repeats twice
function CheckForRepeatingNumbersInCell()
{
    param(
        [System.Array]$sudokuCell
    )

    # $sudokuCell
    $goodCell = $False

    # Create a hashtable for each number
    $hash = @{}

    # For some reason, .Length is supposed to return the number of rows
    # and [0].Count returns the number of columns
    for($i = 0; $i -lt ($sudokuCell.Length); $i++)
    {
        for($j = 0; $j -lt ($sudokuCell[0].Count); $j++)
        {
            $hash[ $sudokuCell[$i][$j] ]++
            if ($hash[ $sudokuCell[$i][$j] ] -gt 1)
            {
                return $goodCell
            }
        }
    }

    $goodCell = $true
    return $goodCell
}


# Arrange each Sudoku 3x3 cell into a bigger 3x3 grid


# Write a function to determine if a column or row
# is exactly nine spaces and has the numbers
# 1 through 9
function CheckTabularStructure()
{
    param (
        [int[]]$tabular
    )
    

}

function CheckRow()
{
    param (
        [int[]]$row
    )

    [System.Collections.ArrayList]$numbersToUse = @(1,2,3,4,5,6,7,8,9)
    [System.Collections.ArrayList]$usedNumbers = @()

    # Check to see if each item is populated with unique values
    # Iterate through each cell in the row
    foreach($cell in $row)
    {
        # Get the cell's value and remove it from $numbersToUse
        # Then add it to $usedNumbers
        # We don't want to add zeros
        if( $numbersToUse -contains $cell -and $usedNumbers -notcontains $cell  )
        {
            $numbersToUse.Remove($cell)
            $usedNumbers.Add($cell)
        }
        else 
        {
            <# Action when all if and elseif conditions are false #>
            Write-Error "The row does not have all unique numbers. Try again"
            return $False
        }
    }

    return $True
}

function CheckColumn()
{
    param (
        [int[]]$column
    )

    # Check to see if each item is populated with unique values

}

function New-NineByNineSudokuMatrix()
{

}

# Build a full 9 x 9 Sudoku Matrix
function New-FullSudokuMatrix()
{
    # How can we build a 9x9 matrix out of 3x3 matrices?
    $size = 9
    $matrix = New-BlankSudokuMatrix

    for($row = 0; $row -lt $size; $row++)
    {
        for($column = 0; $column -lt $size; $column++)
        {
            $matrix[$row][$column]
        }
    }
}

