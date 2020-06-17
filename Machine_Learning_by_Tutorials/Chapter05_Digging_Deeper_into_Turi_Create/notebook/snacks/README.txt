SNACKS DATASET

This is a dataset of 20 different types of snack foods that accompanies the book
Machine Learning by Tutorials from https://www.raywenderlich.com.

The images were taken from the Google Open Images dataset, release 2017_11. 
https://storage.googleapis.com/openimages/web/index.html

Number of images in the train/validation/test splits:
	train    4838
	val      955
	test     952
	total    6745

Total images in each category:
	apple         350
	banana        350
	cake          349
	candy         349
	carrot        349
	cookie        349
	doughnut      350
	grape         350
	hot dog       350
	ice cream     350
	juice         350
	muffin        348
	orange        349
	pineapple     340
	popcorn       260
	pretzel       204
	salad         350
	strawberry    348
	waffle        350
	watermelon    350

To save space in the download, the images were resized so that their smallest 
side is 256 pixels. All EXIF information was removed.

Included are also three CSV files with bounding box annotations for the images
in the dataset, although not all images have annotations and some images have
multiple annotations. The columns in the CSV files are: 

	image_id: 
		the filename of the image without the .jpg extension
	x_min, x_max, y_min, y_max: 
		normalized bounding box coordinates, i.e. in the range [0, 1]
	class_name: 
		the class that belongs to the bounding box
	folder: 
		the class that belongs to the image as a whole, which is also the
	    name of the folder that contains the image

Just like the images from Google Open Images, the snacks dataset is licensed 
under the terms of the Creative Commons license. 

The images are listed as having a CC BY 2.0 license. 
https://creativecommons.org/licenses/by/2.0/

The annotations are licensed by Google Inc. under a CC BY 4.0 license. 
https://creativecommons.org/licenses/by/4.0/

The credits.csv file contains the original URL, author information and license
for each image.
