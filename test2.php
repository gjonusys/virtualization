<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>XUI</title>
</head>
<body>
<p>
<?php
$conn = pg_connect("host=10.0.1.243 port=5432 dbname='postgres' user='postgres' password='1234'");
if (!$conn) {
    echo "An error occurred.\n";
    exit;
   }
   $result = pg_query($conn, "SELECT * FROM data");
   if (!$result) {
    echo "An error occurred.\n";
    exit;
   }
?>
</p>

</body>
</html>
