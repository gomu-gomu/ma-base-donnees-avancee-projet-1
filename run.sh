#!/bin/sh
docker exec eoussama/oracle-database:latest ./setPassword.sh password
docker exec -ti eoussama/oracle-database:latest sqlplus system/password@orclpdb1