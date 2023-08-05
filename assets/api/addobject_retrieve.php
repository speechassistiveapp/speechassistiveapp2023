<?php
header('Content-Type: application/json');

// Replace "your_domain_path" with the correct path to your desired folder
$directoryPath = '/home/zeejrobh/public_html/assets/images/addobject/';

// Fetch the list of image files in the directory with multiple extensions
$imageFiles = glob($directoryPath . "*.{png,jpg,jpeg,gif}", GLOB_BRACE);

// Return only the image file names without the full path
$imageFileNames = array_map('basename', $imageFiles);

// Return the list of image file names as a JSON response
echo json_encode($imageFileNames);
?>
