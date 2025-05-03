#!/bin/bash
# Next-Protection install script

echo "Installing Next-Protection..."

# Install git and python3 if missing (optional, good idea)
if ! command -v git &> /dev/null; then
    echo "Git not found, installing..."
    sudo apt update && sudo apt install -y git
fi

if ! command -v python3 &> /dev/null; then
    echo "Python3 not found, installing..."
    sudo apt update && sudo apt install -y python3
fi

# Clone the repository
git clone https://github.com/next-ninja/Next-Protection.git

# Move into the project directory
cd Next-Protection || exit

# Optionally install Python requirements if you have requirements.txt
# if [ -f "requirements.txt" ]; then
#     echo "Installing Python dependencies..."
#     python3 -m pip install -r requirements.txt
# fi

# Make Next-Protection.py executable (optional)
chmod +x Next-Protection.py

# Run the Next-Protection script
echo "Running Next-Protection.py..."
./Next-Protection.sh
