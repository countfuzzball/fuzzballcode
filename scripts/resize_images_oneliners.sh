# resize an image by percentage
convert image1.png -resize "50%" resize_image1.png


# resize an image by dimensions
convert image1.png -resize 600x800 resize_image1.png


# resize an image, and save it on another folder
convert image1.png -resize 70% new_folder/resize_image1.png


# resize a batch of images, and save resized files as new files
for file in *.png; do resize $file -resize 70% "resize_$file"; done


# resize a batch of images, and save resized files on another folder
for file in *.png; do convert $file -resize 70% "new_folder/resize_$file"; done


# same as above, but if the file names contain spaces
for file in *.png; do convert "$file" -resize 70% "new_folder/resize_$file"; done


# resize a batch of images named "crop_image01.jpg, crop_image02.jpg, etc" and
# save them with the names "resize_image01.jpg, resize_image02.jpg, etc"
for file in crop_*.jpg
do
  convert "$file" -resize 70% "$(echo "$file" | sed -e 's/crop_/resize_/' - )"
done

https://davescripts.com/code/bash-imagemagick/resize-a-batch-of-images-using-convert-and-a-for-loop
