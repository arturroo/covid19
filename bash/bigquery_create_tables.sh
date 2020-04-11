#################################################
# Core BigQuery deploy scripts
# Artur Fejklowicz
#################################################

###################################################
# Create Dataset
bq --location=europe-west6 mk \
--dataset \
--description COVID19 \
af-covid19:csse

###################################################
# External tables
# For those steps files must be present on GCS
# schema v1 - early data with different timestamp format "1/23/20 17:00" for dates (2020-01-22 - 2020-02-01) and schema without latlon
# schema v2 - dates 2020-02-02 - 2020-03-21: new timestamp format and new columns: latlon
# I am lazy and I gave schema control to BQ with autodetect ;)
BUCKET=gs://af-covid19-data
DATA_DIR=csse
TDEF_DIR=bigquery/tables_definitions
TDESC=(
    "schema v1 - day BETWEEN '2020-01-22' AND '2020-02-01'. Timestamp format '1/23/20 17:00'. First schema."
    "schema v2 - day BETWEEN '2020-02-02' AND '2020-03-21'. New timestamp format '2020-03-21T20:43:02' and new columns: latlons."
    "schema v3 - day BETWEEN '2020-03-22' AND now(). New timestamp format '2020-03-23 23:19:34' and new schema: additional columns. China and US splited to City, State, Country."
    )

for i in 1 2; do
    SCHEMA_VER=$i
    TABLE=external_v$SCHEMA_VER
    TDEF=$TDEF_DIR/$TABLE.def
    URI_PREFIX=$BUCKET/$DATA_DIR/v$SCHEMA_VER
    echo "INFO: BQ: create table definition"
    echo "bq mkdef \
        --source_format=CSV \
        --autodetect \
        --hive_partitioning_mode=AUTO \
        --hive_partitioning_source_uri_prefix=$URI_PREFIX \
        $URI_PREFIX/*.csv > $TDEF"
    bq mkdef \
        --source_format=CSV \
        --autodetect \
        --hive_partitioning_mode=AUTO \
        --hive_partitioning_source_uri_prefix=$URI_PREFIX \
        $URI_PREFIX/*.csv > $TDEF

    echo "INFO: sed: add 2 CSV params to table definition"
    sed -ie 's/"quote": "\\""/"quote": "\\"",\n    "allowJaggedRows": true,\n    "skipLeadingRows": 1/' $TDEF
    
    echo "INFO: BQ: create external table"
    bq rm -f af-covid19:csse.$TABLE
    echo "bq mk \
        --description ${TDESC[${i}]} \
        --external_table_definition=$TDEF \
        af-covid19:csse.$TABLE"
    bq mk \
        --description "${TDESC[${i}]}" \
        --external_table_definition=$TDEF \
        af-covid19:csse.$TABLE
done

# schema v3 - "2020-03-23 23:19:34" from day 2020-03-22 till now and new schema, new way with schema included
# new way of load in schema you can specify last_update as STRING and pass schema as parameter to mkdef !!!! not mk
# do not specify in json schema file hive partitioning, BQ will AUTO recognize it and will add day column automatically
# with last_update as STRING I can do view that will parse this string accordingly for each day partition.
# right now this is just to show possibility, because there is not only timestamp format change, but also rest of the schema
# and it is better to build additional table and then apply general view - schema evolution with CSV
SCHEMA_VER=3
TABLE=external_v$SCHEMA_VER
TDEF=$TDEF_DIR/$TABLE.def
URI_PREFIX=$BUCKET/$DATA_DIR/v$SCHEMA_VER
SCHEMA_JSON=bigquery/schemas/af-covid19.csse.$TABLE.json
echo "INFO: BQ: create table definition"
echo "bq mkdef \
    --source_format=CSV \
    --hive_partitioning_mode=AUTO \
    --hive_partitioning_source_uri_prefix=$URI_PREFIX \
    $URI_PREFIX/*.csv \
    $SCHEMA_JSON > $TDEF"
bq mkdef \
    --source_format=CSV \
    --hive_partitioning_mode=AUTO \
    --hive_partitioning_source_uri_prefix=$URI_PREFIX \
    $URI_PREFIX/*.csv \
    $SCHEMA_JSON > $TDEF
    
echo "INFO: sed: modify 2 CSV params in table definition"
sed -ie 's/"allowJaggedRows": false/"allowJaggedRows": true/'  $TDEF
sed -ie 's/"skipLeadingRows": 0/"skipLeadingRows": 1/' $TDEF

echo "INFO: BQ: create external table"
bq rm -f af-covid19:csse.$TABLE
echo "bq mk \
    --description ${TDESC[$SCHEMA_VER]} \
    --external_table_definition=$TDEF \
    af-covid19:data.csse.$TABLE"
bq mk \
    --description "${TDESC[${SCHEMA_VER}]}" \
    --external_table_definition=$TDEF \
    af-covid19:csse.$TABLE


###################################################
# Create main data view
bq mk \
    --use_legacy_sql=false \
    --description 'COVID19 data gathered by Johns Hopkins University Center for Systems Science and Engineering (JHU CSSE). This view gathers CSSE data with different schemas.' \
    --view="$(cat bigquery/sql/af-covid19.csse.data.create.sql)" \
    af-covid19:csse.data


###################################################
# Create materialized view for dashboard - daily job
bq query \
    --use_legacy_sql=false \
    < bigquery/sql/af-covid19.csse.dashboard.create.sql

# Daily insert
bq query \
    --use_legacy_sql=false \
    --parameter day:DATE:2020-04-10 \
    < bigquery/sql/af-covid19.csse.dashboard.daily_insert.sql

# query dasboard materialized view
bq query \
    --use_legacy_sql=false \
    --parameter mv_rows:INT64:5 \
    < bigquery/sql/af-covid19.csse.dashboard.datastudio_select.sql
