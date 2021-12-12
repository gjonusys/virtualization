<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>XUI</title>
</head>
<body>

<?php
$db = pg_connect("host=10.0.1.243 port=5432 dbname=postgres user=postgres password=1234");
if($db != NULL) {
    echo 'Isejo';
} else {
    echo 'Pizda';
}
$query = "SELECT * FROM data";
$result = pg_query($query); 
echo $result;
?>

</body>
</html>
