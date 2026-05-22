# NeuroCover Focus -- Releases

Pilot release distribution for NeuroCover Focus, an adaptive cognitive stability system built by NeuroPause Lab in Ahmedabad, India.

This repository contains only the installer and PowerShell install script. The application's source code is maintained separately.

## Install on Windows 10/11

Paste this single command into PowerShell:

    $s = (iwr 'https://raw.githubusercontent.com/dishantdobariya91-debug/neurocover-releases/main/install.ps1' -UseBasicParsing).Content; if ($s[0] -eq [char]0xFEFF) { $s = $s.Substring(1) }; iex $s

The script will download the MSI, verify its SHA256 hash, run the installer (admin prompt), and launch the app.

## Manual install

Go to the latest release at:

    https://github.com/dishantdobariya91-debug/neurocover-releases/releases/latest

Download the MSI file. You may see Windows security warnings during install -- this is expected for unsigned pilot releases.

## Status

Phase 1 -- Pilot. This release is not yet signed with a publisher certificate. Windows will show security warnings during install. This is expected and will be resolved in future versions.

NeuroCover Focus stores all data locally on your computer and sends nothing to any server.

## Team

Saurabh Patel, Dr. Kinjal Mali, Dishant Dobariya -- Ahmedabad, India.