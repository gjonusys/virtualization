<html>
 <head>
  <title>PHP Test</title>
 </head>
 <body>
 <p>
  <?php 
     $db_connection = pg_connect("host=10.0.1.243 dbname=postgres user=postgres password=1234");
     $result = pg_query($db_connection, "SELECT * FROM data");
     echo var_dump($result);
  ?>
  </p>
 </body>
</html>