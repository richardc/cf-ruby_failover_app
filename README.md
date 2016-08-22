# A test for HA-RDS behaviour


Setup:

    cf login

    cf create-service postgres  M-HA-dedicated-9.5 failover-postgres

    cf push
