<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Phone page</title>
</head>
<body>
<div style="width: 60%; height:500px; background-color: #fbfff0; margin: 0 auto!important; display: grid; grid-template-columns: 1fr 1fr; font-family: Arial, Helvetica, sans-serif;">
<div style="display:flex; justify-content: center; align-items:center">Person</div>
<div style="display:flex; justify-content: center; align-items:center">Number</div>
<?php

include 'vars.php';

$conn = pg_connect("host=".$ip." port=5432 dbname=postgres user=postgres password=1234");
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
    $div1 = '<div style="display:flex; justify-content: center; align-items:center">' . $row[0] . '</div>';

    $div2 = '<div style="display:flex; justify-content: center; align-items:center">';
    $div2 .= '<a href="https://api.whatsapp.com/send?phone='. $row[1] .'">'. $row[1] .'</a></div>';
    

    echo $div1;
    echo $div2;
  }
?> 
</div>

</body>
</html>
