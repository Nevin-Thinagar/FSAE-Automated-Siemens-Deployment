# FSAE-Automated-Siemens-Deployment
A batch script to automatically install Teamcenter, NX, and (optionally) STAR-CCM+, Femap, Teamcenter Visualization, and HEEDS

## Software Version Compatibility
This script was initially created for:
- Eclipse Temurin JDK 21.0.3
  - Transitioning away from Corretto as Siemens uses Temurin internally
- Teamcenter 2606
  - May go back to Teamcenter 2506 depending on Deployment Center and server upgrade situation
- NX 2506
  - Sticking with existing version as there are no major functional improvements with newer versions
- Simcenter STAR-CCM+ 2602
- Simcenter Femap 2026
- Teamcenter Lifecycle Visualization 2606
- HEEDS 2026

## Setup Info
- Make sure to remove the "+" from the STAR-CCM filename or the curl commands will break
- Get the specific version of Temurin from their [Github repo](https://github.com/adoptium/temurin21-binaries/releases) as the website only has the latest versions
