# Create 200 folders, then move "head -n <number> files in the current directory to each of the directories.
# i.e below, 3 files per folder.

for i in `seq 1 200`; do mkdir -p "folder$i"; find . -type f -maxdepth 1 | head -n 3 | xargs -i mv "{}" "folder$i"; done
