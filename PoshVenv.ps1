$script:POSHVENV_HOME=$null
$script:PYTHON_BIN=$null

function Handle-Parameters()
{
  param(
    $params
  )
  $script:arguments = New-Object Collections.Generic.List[string]
  while ($params)
  {
    $param , $params = $params
    switch -regex ($param)
    {
      '-h|--home'
      {
        $value , $params = $params
        $script:POSHPOSHVENV_HOME = $value
        Write-Debug "Setting POSHVENV_HOME to $value"
      }
      '-p|--python'
      {
        $value , $params = $params
        $script:PYTHON_BIN = $value
        Write-Debug "Setting PYTHON_BIN to $value"
      }
      default
      {
        $script:arguments.Add($param)
        Write-Debug "Adding Default Argument"
      }
    }
  }
}

function Handle-DefaultValues()
{
  if ($script:POSHVENV_HOME -eq $null)
  {
    if ($env:POSHVENV_HOME)
    {
      $script:POSHVENV_HOME = $env:POSHVENV_HOME
      Write-Debug "Setting POSHVENV_HOME to $script:POSHVENV_HOME"
    } else
    {
      $script:POSHVENV_HOME = "${env:USERPROFILE}\.poshvenv"
      Write-Debug "Setting POSHVENV_HOME to $script:POSHVENV_HOME"
    }
  }
  if ($script:PYTHON_BIN -eq $null)
  {
    if ($env:POSHVENV_PYTHON_BIN)
    {
      $script:PYTHON_BIN = $env:POSHVENV_PYTHON_BIN
      Write-Debug "Setting PYTHON_BIN to $script:PYTHON_BIN"
    } else
    {
      $script:PYTHON_BIN = "python"
      Write-Debug "Setting PYTHON_BIN to $script:PYTHON_BIN"
    }
  }
}

function Check-Requirements()
{
  try
  {
    $null = Get-Command $script:PYTHON_BIN -ErrorAction Stop
  } catch
  {
    Write-Error "Python not found at $script:PYTHON_BIN"
    exit 1
  }
  if (-Not (Test-Path -Path $script:POSHVENV_HOME))
  {
    New-Item -Path $script:POSHVENV_HOME -ItemType Directory -Force
    Write-Debug "Path '$script:POSHVENV_HOME' created."
  }
}

function List-Venvs()
{
  $venvs = $(Get-ChildItem -Path $script:POSHVENV_HOME -Directory)
  $venvs | ForEach-Object { Write-Host $_.Name }
}

function Create-Venv()
{
  param(
    $Name
  )
  Write-Host "Creating Venv $Name"
  $null = New-Item -Path "$script:POSHVENV_HOME\$Name" -ItemType Directory
  & $script:PYTHON_BIN -m venv "$script:POSHVENV_HOME\$Name"
}

function Delete-Venv()
{
  param(
    $Name
  )
  Write-Host "Deleting Venv $Name"
  Remove-Item -Path "$script:POSHVENV_HOME\$Name" -Recurse
}

function Activate-Venv()
{
  param(
    $Name
  )
  Write-Host "Activating Venv $Name"
  & "${script:POSHVENV_HOME}\${Name}\Scripts\Activate.ps1"
}

function Deactivate-Venv()
{
  Write-Host "Deactivating Venv"
  deactivate
}

function Init-PoshVenv()
{
  return @"
  #!/usr/bin/env pwsh
`$null = New-Module poshvenv {
  function search_recursive() {
    param(
        `$Path
    )
    `$PoshVenvFile = $null
    while ((`$PoshVenvFile -eq `$null) -and ( `$Path -ne "")) {
      try {
        if (test-path -PathType "Leaf" ([system.io.path]::combine(`$Path, ".poshvenv"))) {
          `$PoshVenvFile = ([system.io.path]::combine(`$Path, ".poshvenv"))
          return `$PoshVenvFile
        }
      } catch {
      }
      `$Path = `$Path | Split-Path -parent
    }
  }

  function Set-Location
  {
    param(
      [string]`$Path
    )

    # Call the original Set-Location command
    Microsoft.PowerShell.Management\Set-Location `$Path

    `$PoshVenvFile = search_recursive (`$pwd)
    if (`$PoshVenvFile)
    {
      PoshVenv activate `$(Get-Content `$PoshVenvFile)
    } else
    {
      if (`$env:VIRTUAL_ENV)
      {
        PoshVenv deactivate
      }
    }
  }

  Export-ModuleMember -Function @(
    "Set-Location"
  )
}
"@
}

# Autobox to ArrayList
[System.Collections.ArrayList]$argsArray = $args

# Handle DebugLogging
if ($argsArray -AND $argsArray.Contains("-Debug"))
{
  $DebugPreference = "Continue"
  $argsArray.Remove("-Debug")
}

Handle-Parameters $argsArray
Handle-DefaultValues

Check-Requirements

# Handle-DefaultArgs
switch ($argsArray[0])
{
  'create'
  {
    Create-Venv $argsArray[1]
  }
  'delete'
  {
    Delete-Venv $argsArray[1]
  }
  'activate'
  {
    Activate-Venv $argsArray[1]
  }
  'deactivate'
  {
    Deactivate-Venv
  }
  'init'
  {
    Init-PoshVenv
  }
  default
  {
    List-Venvs
  }
}
