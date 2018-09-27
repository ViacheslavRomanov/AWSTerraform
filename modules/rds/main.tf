resource "aws_db_instance" "db_instance" {
  count = "${var.rdsCreateCluster ? 0 : var.rdsInstanceCount}"

  identifier = "${lower(var.rdsName)}-rds-${lower(var.rdsEnvironment)}-${count.index+1}"
  allocated_storage = "${var.rdsAllocatedStorageSize}"
  storage_type = "${var.rdsStorageType}"
  iops = "${var.rdsIOPS}"
  engine = "${var.rdsEngine}"
  engine_version = "${var.rdsEngineVersion}"
  instance_class = "${var.rdsInstanceClass}"
  replicate_source_db = "${var.rdsReplicateSourceDB}"
  backup_retention_period = "${var.rdsBackupRetentionPeriod}"
  backup_window = "${var.rdsBackupTimeWindow}"
  copy_tags_to_snapshot = "${var.rdsIsCopyTagsToSnapshot}"
  skip_final_snapshot = "${var.rdsIsSkipFinalSnapshot}"
  final_snapshot_identifier = "${lower(var.rdsName)}-rds-${lower(var.rdsEnvironment)}-${md5(timestamp())}"

  name = "${var.rdsDBName}"
  username = "${var.rdsDBUser}"
  password = "${var.rdsDBPassword}"
  port = "${lookup(var.rdsDefaultPort, var.rdsEngine)}"
  character_set_name = "${var.rdsCharacterSetName}"

  vpc_security_group_ids = [
    "${var.rdsVPCSGIdList}"]
  db_subnet_group_name = "${var.rdsDBSubnetGroupName == "" ? aws_db_subnet_group.db_subnet_group.id : var.rdsDBSubnetGroupName}"
  parameter_group_name = "${length(var.rdsDBParameterGroupName) > 0 ? var.rdsDBParameterGroupName : aws_db_parameter_group.db_parameter_group.id}"
  publicly_accessible = "${var.rdsIsPublic}"
  storage_encrypted = "${var.rdsIsStorageEncrypted}"
  multi_az = "${var.rdsIsMultiAZ}"

  allow_major_version_upgrade = "${var.rdsIsAllowMajorVersionUpgrade}"
  auto_minor_version_upgrade = "${var.rdsIsAutoMinorVersionUpgrade}"
  apply_immediately = "${var.rdsIsApplyImmediately}"
  maintenance_window = "${var.rdsMaintenanceTimeWindow}"

  monitoring_interval = "${var.rdsMonitoringInterval}"

  tags {
    Name = "${var.rdsName}"
    Environment = "${var.rdsEnvironment}"
  }

  lifecycle {
    create_before_destroy = true,
    ignore_changes = [
      "final_snapshot_identifier",
      "replicate_source_db"],
  }

  depends_on = [
    "aws_db_subnet_group.db_subnet_group",
    "aws_db_parameter_group.db_parameter_group"]
}

resource "aws_rds_cluster_instance" "rds_cluster_instance" {
  count = "${var.rdsCreateCluster ? var.rdsInstanceCount : 0}"

  identifier = "${lower(var.rdsName)}-cluster-${lower(var.rdsEnvironment)}-${count.index+1}"
  cluster_identifier = "${aws_rds_cluster.rds_cluster.id}"
  instance_class = "${var.rdsInstanceClass}"

  db_subnet_group_name = "${var.rdsDBSubnetGroupName == "" ? aws_db_subnet_group.db_subnet_group.id : var.rdsDBSubnetGroupName}"
  apply_immediately = "${var.rdsIsApplyImmediately}"
  db_parameter_group_name = "${var.rdsInstanceParameterGroup == "" ? aws_db_parameter_group.db_parameter_group.id : var.rdsInstanceParameterGroup}"

  tags {
    Name = "${lower(var.rdsName)}-cluster-${lower(var.rdsEnvironment)}-${count.index+1}"
    Environment = "${var.rdsEnvironment}"
  }

  depends_on = [
    "aws_rds_cluster.rds_cluster",
    "aws_db_subnet_group.db_subnet_group",
    "aws_db_parameter_group.db_parameter_group"]
}

resource "aws_rds_cluster" "rds_cluster" {
  count = "${var.rdsCreateCluster ? 1 : 0}"

  cluster_identifier = "${lower(var.rdsName)}-cluster-${lower(var.rdsEnvironment)}"
  engine = "${var.rdsEngine}"
  engine_version = "${var.rdsEngineVersion}"

  backup_retention_period = "${var.rdsBackupRetentionPeriod}"
  preferred_backup_window = "${var.rdsBackupTimeWindow}"
  preferred_maintenance_window = "${var.rdsMaintenanceTimeWindow}"

  skip_final_snapshot = "${var.rdsIsSkipFinalSnapshot}"
  final_snapshot_identifier = "${lower(var.rdsName)}-cluster-${lower(var.rdsEnvironment)}-${md5(timestamp())}"

  db_subnet_group_name = "${var.rdsDBSubnetGroupName == "" ? aws_db_subnet_group.db_subnet_group.id : var.rdsDBSubnetGroupName}"
  vpc_security_group_ids = [
    "${var.rdsVPCSGIdList}"]

  storage_encrypted = "${var.rdsIsStorageEncrypted}"
  apply_immediately = "${var.rdsIsApplyImmediately}"
  db_cluster_parameter_group_name = "${length(var.rdsClusterParameterGroup) > 0 ? aws_db_parameter_group.db_parameter_group.id : var.rdsClusterParameterGroup}"
  //availability_zones  = ["${split(",", (lookup(var.rdsAvailabilityZoneMap, var.rdsRegion)))}"]

  database_name = "${var.rdsDBName}"
  master_username = "${var.rdsDBUser}"
  master_password = "${var.rdsDBPassword}"

  tags {
    Name = "${lower(var.rdsName)}-cluster-${lower(var.rdsEnvironment)}"
    Environment = "${var.rdsEnvironment}"
  }

  lifecycle {
    create_before_destroy = true,
    ignore_changes = [
      "final_snapshot_identifier"],
  }
  depends_on = [
    "aws_db_subnet_group.db_subnet_group",
    "aws_db_parameter_group.db_parameter_group"]
}

resource "aws_db_subnet_group" "db_subnet_group" {
  count = "${var.rdsDBSubnetGroupName == "" ? 1 : 0}"

  name = "${lower(var.rdsName)}-db_subnet_group-for-${var.rdsCreateCluster ? "cluster" : "rds"}-${lower(var.rdsEnvironment)}"
  description = "My ${lower(var.rdsName)}-db_subnet_group-for-${var.rdsCreateCluster ? "cluster" : "rds"}-${lower(var.rdsEnvironment)} group of subnets"
  subnet_ids = [
    "${var.rdsSubnetIdList}"]

  tags {
    Name = "${lower(var.rdsName)}-db_subnet_group-${lower(var.rdsEnvironment)}"
    Environment = "${var.rdsEnvironment}"
  }
}

resource "aws_db_parameter_group" "db_parameter_group" {
  count = "${length(var.rdsDBParameterGroupName) > 0 ? 0 : 1}"

  name = "${lower(var.rdsName)}-db-parameter-group-for-${var.rdsCreateCluster ? "cluster" : "rds"}-${lower(var.rdsEnvironment)}"
  description = "RDS ${lower(var.rdsName)}-db_parameter_group-for-${var.rdsCreateCluster ? "cluster" : "rds"}-${lower(var.rdsEnvironment)} parameter group for ${var.rdsEngine}"
  family = "${var.rdsDBGroupFamily[var.rdsEngine]}"
  parameter = "${var.rdsDBParametersDefault[var.rdsEngine]}"

  tags {
    Name = "${lower(var.rdsName)}-db_parameter_group-${lower(var.rdsEnvironment)}"
    Environment = "${var.rdsEnvironment}"
  }

}
