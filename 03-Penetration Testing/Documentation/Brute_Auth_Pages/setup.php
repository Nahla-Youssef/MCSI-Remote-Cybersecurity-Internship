<?php
// Database configuration
$servername = "localhost";
$username = "root";
$password = "";
$dbname = "brute_auth_pages";

// Create connection
$conn = new mysqli($servername, $username, $password);

// Check connection
if ($conn->connect_error) {
    die("Connection failed: " . $conn->connect_error);
}

// Create database
$sql = "CREATE DATABASE IF NOT EXISTS $dbname";
if ($conn->query($sql) === TRUE) {
    echo "Database created successfully or already exists.<br>";
} else {
    die("Error creating database: " . $conn->error);
}

// Select the database
$conn->select_db($dbname);

// Create users table
$sql = "CREATE TABLE IF NOT EXISTS users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL
)";
if ($conn->query($sql) === TRUE) {
    echo "Table 'users' created successfully or already exists.<br>";
} else {
    die("Error creating table: " . $conn->error);
}

// Check if 1,000 users already exist
$result = $conn->query("SELECT COUNT(*) as user_count FROM users");
$row = $result->fetch_assoc();

if ($row['user_count'] < 1000) {
    // Insert user accounts if there are less than 1,000
    for ($i = 1; $i <= 1000; $i++) {
        $username = $i;
        $password = "password$i"; // Example weak password
        $stmt = $conn->prepare("INSERT IGNORE INTO users (username, password) VALUES (?, ?)");
        $stmt->bind_param("ss", $username, $password);
        $stmt->execute();
    }
    echo "1000 user accounts created successfully.<br>";
} else {
    echo "User accounts already populated.<br>";
}

// Close the connection
$conn->close();
?>
