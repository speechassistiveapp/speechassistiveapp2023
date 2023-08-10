<?php
header('Content-Type: application/json');

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    if (isset($_POST['image']) && isset($_POST['filename'])) {
        $base64Image = $_POST['image'];
        $filename = $_POST['filename'];

        // Decode base64 image data
        $decodedImage = base64_decode($base64Image);
        

        // Replace "your_domain_path" with the correct path to your desired folder
        $uploadPath = '/home/zeejrobh/public_html/assets/images/profile/' . $filename;

        // Save the image to the server
        if (file_put_contents($uploadPath, $decodedImage)) {
            $response = array('status' => 'success', 'message' => 'Image uploaded successfully.');
            echo json_encode($response);
        } else {
            $response = array('status' => 'error', 'message' => 'Failed to upload image.');
            echo json_encode($response);
        }
    } else {
        $response = array('status' => 'error', 'message' => 'Invalid parameters.');
        echo json_encode($response);
    }
} else {
    $response = array('status' => 'error', 'message' => 'Invalid request method.');
    echo json_encode($response);
}
?>
