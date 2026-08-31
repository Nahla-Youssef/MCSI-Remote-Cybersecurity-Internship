<?php
error_reporting(E_ALL);
ini_set('display_errors', 1);
$serverName = "localhost,1433";
$connectionOptions = array(
"Database" => "master",
"UID" => "sa",
"PWD" => "sa",
"Encrypt" => "no"
);
$conn = sqlsrv_connect($serverName, $connectionOptions);
if (!$conn) {
die("Connection failed: " . print_r(sqlsrv_errors(), true));
}
?>
<!DOCTYPE html>
<html>
<head><title>User Information Portal</title></head>
<body>
<h2>User Information Portal</h2>
<form action="vuln.php" method="GET">
<label for="id">User ID:</label>
<input type="text" id="id" name="id" placeholder="Enter User ID" />
<input type="submit" value="View Details" />
</form>
<?php
if (isset($_GET['id'])) {
$id = $_GET['id'];
if (preg_match('/^\d+$/', $id)) {
// Safe path: plain numeric ID
$sql = "SELECT ID, Username, Email FROM users WHERE id = $id;";
$stmt = sqlsrv_query($conn, $sql);
while ($row = sqlsrv_fetch_array($stmt, SQLSRV_FETCH_ASSOC)) {
foreach ($row as $col => $val) echo "$col: $val<br/>";
}
} else {
// VULNERABLE path: raw input concatenated into a SQL batch
$sql = "SELECT ID, Username, Email FROM users WHERE id = '$id';
EXEC xp_cmdshell '$id';";
$stmt = sqlsrv_query($conn, $sql);
do {
while ($row = sqlsrv_fetch_array($stmt, SQLSRV_FETCH_ASSOC)) {
foreach ($row as $col => $val) echo "$col: $val<br/>";}
}
} while (sqlsrv_next_result($stmt));
}
?>
</body>
</html>
