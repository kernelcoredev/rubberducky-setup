# Rubber Ducky Setup (repo) 

**This repository contains a small installer, example scripts, and a helper library (`rdss`) to make writing rubber-ducky (HID keyboard) scripts easier.**  
> Note: *rdss* is the helper library/package (the third-party convenience layer). The actual keystroke scripts you write are separate files that the library runs.

---

## What is this repo?
This repo provides:
- `hid.sh` — an installer/setup script to enable USB HID gadget mode on a Raspberry Pi 5. (Copy the **code** and paste it; do not blindly run unknown scripts.)
- `rdss` (the helper library/package) — a lightweight Python helper that makes writing rubber-ducky style scripts simpler (installable via a `.deb` packaged in this repo).
- Example `.rds` or `.txt` script files demonstrating how to write keystroke sequences.

**Important:** `rdss` in this repo is a convenience library you can install so writing scripts is easier. The actual scripted behavior (the commands that type things on the host) are your script files — treat them as the payload that rdss executes.

---

## Safety & Ethics — read this first 
**Only use these tools on machines you own or have explicit permission to test.**  
Unauthorized use (malicious access, data theft, or social engineering) is illegal and unethical. The author is not responsible for misuse.

---

## Quick overview — components
- `hid.sh` — installs/configures USB gadget support and helper files on the Pi. **Copy the code** from `downloads/hid.sh` and paste it into the Pi (or curl it from this repo if you trust it).
- `rdss` package — the helper library that provides functions/CLI to load and run keystroke scripts. Packaged as `.deb` for easy apt installation.
- `examples/` — sample scripts (how to format keystroke sequences).

---

## Install the helper library (`rdss`) — recommended
(Recommended for users who want a simple install and easy updates.)

**Run these commands:**
```bash
# add the APT source (run once)
echo "deb [trusted=yes] https://kernelcoredev.github.io/rdss/ ./" | sudo tee /etc/apt/sources.list.d/rdss.list

# update package lists
sudo apt update

# install the helper package (rdss)
sudo apt install -y rdss
