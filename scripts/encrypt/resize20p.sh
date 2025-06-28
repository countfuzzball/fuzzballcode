#Resize all jpg images in the current directory to 20% their original size in a folder called 'resized'
#will install imagemagick if not already installed.

sudo apt install imagemagick


for f in *; do
cd "$f"
mkdir resized

for file in *.jpg; do convert "$file" -resize 20% "resized/resize_$file"; echo $file processed; sleep 1; done
pwd
cd ..

#for file in *.jpg; do convert "$file" -resize 20% "resized/resize_$file"; echo $file processed; sleep 1; done
done
