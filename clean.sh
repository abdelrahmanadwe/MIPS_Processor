#!/bin/bash
# clean.sh
# Script to clean up QuestaSim / ModelSim generated files and compilation directories

echo "Cleaning up QuestaSim/ModelSim temporary files and directories..."

# Remove compilation libraries
if [ -d "work" ]; then
    rm -rf work/
    echo "Removed 'work/' directory"
fi

# Remove log and database files
files_to_remove=("transcript" "vsim.wlf" "modelsim.ini" "vish_stacktrace.vstf")

for file in "${files_to_remove[@]}"; do
    if [ -f "$file" ]; then
        rm -f "$file"
        echo "Removed '$file'"
    fi
done

echo "Cleanup completed successfully!"
