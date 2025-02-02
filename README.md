# PoshVenv - A PowerShell native Pyhon Virtual Environment Manager

PoshVenv is a Powershell native implementation to manage Pythin Virtual Environments.

## Installation

Just clone the repository and make the `PoshVenv.ps1` available in your PATH.

To enable automatic venv activation, also add the following line to your Powershell profile:

```powershell
Invoke-Expression(PoshVenv init)
```

## Usage

### Create a new virtual environment
```powershell
PoshVenv create <env_name>
```
Creates a new virtual environment with the specified name.

### Activate a virtual environment
```powershell
PoshVenv activate <env_name>
```
Activates the specified virtual environment.

### Deactivate the current virtual environment
```powershell
PoshVenv deactivate
```
Deactivates the currently active virtual environment.

### List all virtual environments
```powershell
PoshVenv list
```
Lists all available virtual environments.

### Remove a virtual environment
```powershell
PoshVenv remove <env_name>
```
Removes the specified virtual environment.

### Automatic venv activation

Make sure to follow the installation instructions to enable automatic venv activation.

To configure automatic venv activation, add a `.poshvenv`file into the root of your project. The file should contain the name of the virtual environment to activate.

Once you change your directory into the folder, the venv will be activated automatically.
Leaving the folder will deactivate the venv.

Search happens recursively from the current directory to the root of the drive.
