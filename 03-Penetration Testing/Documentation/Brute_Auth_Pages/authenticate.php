<?php
session_start();
$db = new PDO('mysql:host=localhost;dbname=brute_auth_pages', 'root', '');

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    // Validate CSRF token
    if (!hash_equals($_SESSION['csrf_token'], $_POST['csrf_token'])) {
        die("CSRF token validation failed.");
    }

    // Validate credentials
    $username = $_POST['username'];
    $password = $_POST['password'];
    $stmt = $db->prepare("SELECT password FROM users WHERE username = ?");
    $stmt->execute([$username]);
    $user = $stmt->fetch();

    if ($user && $user['password'] === $password) {
        echo "Login successful!";
	// Store the username in the session for later use
        $_SESSION['username'] = $username;
        
        // Redirect to a dashboard or welcome page after successful login
        header("Location: dashboard.php");
        exit();  // Always exit after a redirect
    } else {
        echo "Invalid credentials.";
    }
}
?>
