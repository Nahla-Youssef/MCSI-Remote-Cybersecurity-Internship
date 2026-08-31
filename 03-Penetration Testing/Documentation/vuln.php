<!DOCTYPE html>
<html>
<head>
    <title>Vulnerable Web Application</title>
</head>
<body>
    <h1>Command Injection Demo</h1>
    <form method="POST">
        <label for="command">Enter a command to run on the server:</label><br>
        <input type="text" id="command" name="command" placeholder="Enter command here"><br><br>
        <input type="submit" value="Run Command">
    </form>
    <?php
    if ($_SERVER["REQUEST_METHOD"] == "POST") {
        // Get user input from the form
        $command = $_POST['command'];
        // Vulnerable line: This directly passes user input to system() without sanitization
        echo "<pre>" . shell_exec($command) . "</pre>";
    }
    ?>
</body>
</html>
