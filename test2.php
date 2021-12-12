<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>XUI</title>
</head>
<body>
<div style="width: 100%; height:500px; backrgound-color: #fbfff0; margin: 0 auto!important; display: flex; justify-content: center;">
<div style="width: 50%;">Person</div>
<div style="width: 50%;">Number</div>
<?php

$conn = pg_connect("host=10.0.1.243 port=5432 dbname=postgres user=postgres password=1234");
if (!$conn) {
  echo "An error occurred.\n";
  exit;
}

$result = pg_query($conn, "SELECT * FROM data");
if (!$result) {
  echo "An error occurred.\n";
  exit;
}

while ($row = pg_fetch_row($result)) {
    echo "<div>" . $row[0] . "</div>";
    echo "<div>" . $row[1] . "</div>";
  }
?> 
</div>

</body>
</html>
