CREATE TABLE IF NOT EXISTS data (
  name varchar(255),
  number varchar(12) PRIMARY KEY
  );
    INSERT INTO data VALUES('Emilis', '+37011111111');
    INSERT INTO data VALUES('Julius', '+37011111114');
    INSERT INTO data VALUES('Deividas', '+37011111113');
    INSERT INTO data VALUES('Gytis', '+37011111112');
ALTER TABLE data OWNER TO "postgres";
