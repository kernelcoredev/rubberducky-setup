#!/bin/bash
set -e

echo "================================================"
echo "            Rubber ducky setup"
echo "================================================"
echo ""

if [ "$EUID" -ne 0 ]; then 
    echo "Error: Please run as root (use sudo)"
    exit 1
fi

echo "[1/5] Backing up config files..."
cp /boot/firmware/config.txt /boot/firmware/config.txt.backup
cp /boot/firmware/cmdline.txt /boot/firmware/cmdline.txt.backup
echo "Backups created"

echo ""
echo "[2/5] Configuring /boot/firmware/config.txt..."
if ! grep -q "dtoverlay=dwc2" /boot/firmware/config.txt; then
    echo "dtoverlay=dwc2,dr_mode=peripheral" >> /boot/firmware/config.txt
    echo "Added dwc2 overlay"
else
    echo "dwc2 overlay already present"
fi

echo ""
echo "[3/5] Configuring /boot/firmware/cmdline.txt..."
CMDLINE=$(cat /boot/firmware/cmdline.txt)
if [[ ! "$CMDLINE" =~ "modules-load=dwc2,libcomposite" ]]; then
    # Add after rootwait
    sed -i 's/rootwait/rootwait modules-load=dwc2,libcomposite/' /boot/firmware/cmdline.txt
    echo "Added modules to cmdline.txt"
else
    echo "Modules already present in cmdline.txt"
fi

echo ""
echo "[4/5] Creating USB HID gadget script..."
cat > /usr/local/bin/usb_hid_gadget.sh << 'EOF'
#!/bin/bash
# USB HID Gadget Configuration Script

cd /sys/kernel/config/usb_gadget/
mkdir -p mykeyboard
cd mykeyboard

echo 0x1d6b > idVendor  # Linux Foundation
echo 0x0104 > idProduct # Multifunction Composite Gadget
echo 0x0100 > bcdDevice # v1.0.0
echo 0x0200 > bcdUSB    # USB2

mkdir -p strings/0x409
echo "fedcba9876543210" > strings/0x409/serialnumber
echo "Pi5 HID" > strings/0x409/manufacturer
echo "USB Keyboard" > strings/0x409/product

mkdir -p functions/hid.usb0
echo 1 > functions/hid.usb0/protocol
echo 1 > functions/hid.usb0/subclass
echo 8 > functions/hid.usb0/report_length

echo -ne \\x05\\x01\\x09\\x06\\xa1\\x01\\x05\\x07\\x19\\xe0\\x29\\xe7\\x15\\x00\\x25\\x01\\x75\\x01\\x95\\x08\\x81\\x02\\x95\\x01\\x75\\x08\\x81\\x03\\x95\\x05\\x75\\x01\\x05\\x08\\x19\\x01\\x29\\x05\\x91\\x02\\x95\\x01\\x75\\x03\\x91\\x03\\x95\\x06\\x75\\x08\\x15\\x00\\x25\\x65\\x05\\x07\\x19\\x00\\x29\\x65\\x81\\x00\\xc0 > functions/hid.usb0/report_desc

mkdir -p configs/c.1/strings/0x409
echo "Config 1" > configs/c.1/strings/0x409/configuration
echo 250 > configs/c.1/MaxPower

ln -s functions/hid.usb0 configs/c.1/

UDC_DEVICE=$(ls /sys/class/udc | head -n 1)
echo $UDC_DEVICE > UDC

echo "USB HID Gadget configured successfully"
EOF

chmod +x /usr/local/bin/usb_hid_gadget.sh
echo "Created /usr/local/bin/usb_hid_gadget.sh"

echo ""
echo "[5/5] Creating systemd service..."
cat > /etc/systemd/system/usb-hid-gadget.service << 'EOF'
[Unit]
Description=USB HID Gadget
After=network.target

[Service]
Type=oneshot
ExecStart=/usr/local/bin/usb_hid_gadget.sh
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable usb-hid-gadget.service
echo "Service enabled"

echo ""
echo "================================================"
echo "Setup Complete"
echo "================================================"
echo ""
echo "IMPORTANT NOTES:"
echo "1. You need to REBOOT for changes to take effect"
echo "2. After reboot, connect the USB-C port (near power button) to target computer"
echo "3. The device will appear as a USB keyboard"
echo "4. Use /dev/hidg0 to send keystrokes"
echo ""
echo "Backups saved as:"
echo "  - /boot/firmware/config.txt.backup"
echo "  - /boot/firmware/cmdline.txt.backup"
echo ""
read -p "Reboot now? (y/n): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "Rebooting..."
    reboot
else
    echo "Remember to reboot before testing!"
fi
