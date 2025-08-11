# ZoomRecover-Windows

**Fix Zoom Error 1132 or avoid fingerprinting by running Zoom in a sandboxed Windows environment.**

This project provides a PowerShell-based utility to isolate Zoom under a separate local Windows user account (`ZoomLocal`) that runs Zoom independently of your main profile. This is useful if you've been shadow-banned or locked out of meetings due to persistent Zoom fingerprinting.

---

## 💡 Features

- ✅ Creates a local Windows user named `ZoomLocal` (with random password)
- ✅ Starts and configures the **Secondary Logon** service
- ✅ Removes Zoom-related registry fingerprints:
  - `HKEY_CLASSES_ROOT\ZoomPhoneCall`
  - `HKEY_CLASSES_ROOT\ZoomPhoneSMS`
- ✅ Automatically detects Zoom's install location
- ✅ Creates a **scheduled task** to run Zoom as `ZoomLocal` silently
- ✅ Creates a **desktop shortcut** to launch Zoom without entering a password
- ✅ Optionally hides the `ZoomLocal` user from the login screen

---

## 🖥 Requirements

- Windows 10 or 11
- PowerShell 5.1+
- Admin privileges (required to create user and registry edits)

---

## 🚀 How to Use

1. Download or clone this repository:
   ```bash
   git clone https://github.com/Twinboi90/ZoomRecover-Windows.git
   cd ZoomRecover-Windows
