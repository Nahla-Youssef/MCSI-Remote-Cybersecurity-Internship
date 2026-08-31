<?php
// XSS Blacklist filters
$blacklist = [
    "<script>", "</script>", "<img>", "<svg>", "onload=", "onerror=",
    "alert(", "prompt(", "confirm(", "javascript:", "document.cookie",
    "window.location", "eval(", "setTimeout(", "setInterval(",
    "innerHTML", "outerHTML", "src=", "href=", "<iframe>", "</iframe>",
    "expression(", "vbscript:", "style=", "onmouseover=", "onfocus=",
    "onblur=", "onclick=", "onkeypress=", "onkeyup=", "onkeydown="
];

// Function to check for blacklisted words
function is_blacklisted($input, $blacklist) {
    // Weak blacklisting: no decoding, no normalization
    foreach ($blacklist as $word) {
        // Case-insensitive match for raw strings
        if (strpos($input, $word) !== false) {
            return true;
        }
    }
    return false;
}

// Handle form submission
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $user_input = $_POST['user_input'];
    
    // Check if input contains any blacklisted words
    if (is_blacklisted($user_input, $blacklist)) {
        echo "Input rejected: contains blacklisted content.";
    } else {
        // Directly echo input into the page (vulnerable to XSS)
        echo $user_input;
    }
}
?>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Insecure XSS Filter</title>
</head>
<body>
    <h1>Vulnerable XSS Web App</h1>
    <form action="" method="POST">
        <label for="user_input">Enter some text:</label><br>
        <input type="text" id="user_input" name="user_input" size="100"><br><br>
        <input type="submit" value="Submit">
    </form>
</body>
</html>
