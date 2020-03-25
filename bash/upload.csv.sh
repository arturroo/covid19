SRCPATH=csse_covid_19_data/csse_covid_19_daily_reports
DSTPATH=gs://af-covid19-data/csse_covid_19_daily_reports

for FILE in `find csse_covid_19_data/csse_covid_19_daily_reports -name *.csv`; do
  DAY=`basename $FILE .csv`
  FILENAME=`basename $FILE`
  m=`echo -ne $DAY | awk -F '-' '{print $1}'`
  d=`echo -ne $DAY | awk -F '-' '{print $2}'`
  y=`echo -ne $DAY | awk -F '-' '{print $3}'`
  DAY=$y-$m-$d
  echo day=$DAY
  gsutil cp $SRCPATH/$FILENAME $DSTPATH/day=$DAY/${DAY}.csv
done