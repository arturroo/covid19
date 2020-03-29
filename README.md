# covid19
This repo hass all what is needed to make my Covid19 dashboard: Visualization of developments of Corona virus pandemic.
I have done this in my free time. There are many better dashboards, but I have done it because:
1. I needed more sofisticated statistics like new per day, 
that I could do only myself as my data science and engineering knowledge and intuition allows me.

2. I wanted to show how easy and fast it is to move from classic HADOOP to Cloud, where infrastructure bounduaries are only 
quotas you put your self on a project. Specially **Google Cloud** as exchanger for Hadoop is very powerfull.

The data pipeline is so:
1. Get file from CSSE github on operating system with Google Cloud SDK installed and configured.
`git pull https://github.com/CSSEGISandData/COVID-19.git 
`
2. Upload new CSV file to Google Cloud Storage (GS) into partition directory with the same structure as in Hive with proper schema version:
`gsutil cp csse_covid_19_data/csse_covid_19_daily_reports/03-25-2020.csv gs://af-covid19-data/csse/v3/day=2
020-03-25/2020-03-25.csv`
On this structure (same as in Hive) is applied external table in Google BigQuery.
On the external tables with different schema is applied view with UNION ALL for refreshing all the data when needed.

3. Execute insert aggregates of this day into materialized view.

4. Run DataStudio Dashboard to see the new data. Auto Refresh is every 12h.

I will develop more this dashboard to check what else can I get from the data and hope that it could have the meaning
for people in this hard time.
