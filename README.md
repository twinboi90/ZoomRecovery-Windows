# ZoomRecover-Windows

This project provides a PowerShell script and a launcher to isolate Zoom usage under a separate local Windows user to avoid fingerprinting issues (e.g., Zoom Error 1132).

## Features
- Creates `ZoomLocal` user with a random password
- Deletes ZoomPhone registry keys
- Creates a scheduled task to run Zoom as `ZoomLocal`
- Optionally hides the user from login screen
- Creates shortcut to launch Zoom without prompts

## Usage
Double-click the `.bat` file to run the setup script. It must be run as administrator.
