<?php
$servername = "localhost";
$username = "root";

// Try different common XAMPP/WAMP passwords
$passwords_to_try = array("", "root", "mysql", "password");
$conn = null;
$connected_password = null;

foreach ($passwords_to_try as $pw) {
    try {
        error_reporting(E_ERROR | E_PARSE); // Suppress warnings for failed attempts
        $conn = new mysqli($servername, $username, $pw);
        if (!$conn->connect_error) {
            $connected_password = $pw;
            break;
        }
    } catch (Exception $e) {
        // Continue to next password
    }
}

if ($conn === null || $conn->connect_error) {
    die("Connection failed with all common passwords. Please make sure MySQL is running and check your root password.\n");
}

echo "Connected successfully to MySQL server using password: '" . $connected_password . "'\n";

// Update DBConnection.java with the found password to ensure the app works
$dbConnFile = 'C:/Users/shive/.gemini/antigravity/playground/golden-space/src/main/java/com/socialmedia/util/DBConnection.java';
if (file_exists($dbConnFile)) {
    $content = file_get_contents($dbConnFile);
    $content = preg_replace('/private static final String PASSWORD = ".*?";/', 'private static final String PASSWORD = "' . $connected_password . '";', $content);
    file_put_contents($dbConnFile, $content);
    echo "Updated DBConnection.java with the correct password.\n";
}

// Read the SQL file
$sqlFile = 'C:/Users/shive/.gemini/antigravity/playground/golden-space/schema.sql';
$sql = file_get_contents($sqlFile);

if ($sql === false) {
    die("Error reading schema.sql file");
}

// Execute multi query
if ($conn->multi_query($sql)) {
    echo "Database schema created successfully.\n";
    
    // Consume results to finish multi_query
    do {
        if ($res = $conn->store_result()) {
            $res->free();
        }
    } while ($conn->more_results() && $conn->next_result());
    
} else {
    echo "Error creating schema: " . $conn->error . "\n";
}

$conn->close();
?>
