[![ducker: [noun] a person or thing that ducks](ducker_definition.png)](https://www.dictionary.com/browse/ducker)

# 🦆 Ducker

Small docker image with [DuckDB](https://github.com/duckdb/duckdb) and extensions pre-installed!

The extensions included and loaded are:
  * [fts](https://duckdb.org/docs/extensions/full_text_search)
  * [httpfs](https://duckdb.org/docs/extensions/httpfs.html)
  * [icu](https://duckdb.org/2022/01/06/time-zones.html)
  * [json](https://duckdb.org/docs/extensions/json)
  * [parquet](https://duckdb.org/docs/data/parquet)
  * [mysql](https://duckdb.org/docs/extensions/mysql)
  * [postgres](https://duckdb.org/docs/extensions/postgres)
  * [sqlite](https://duckdb.org/docs/extensions/sqlite)
  * [substrait](https://duckdb.org/docs/extensions/substrait)
  * [iceberg](https://duckdb.org/docs/extensions/iceberg)
  * [arrow](https://duckdb.org/docs/extensions/arrow)
  * [spatial](https://duckdb.org/docs/extensions/spatial)
  * [prql](https://github.com/ywelsch/duckdb-prql)
    * This means `ducker` can quack SQL or [PRQL](https://github.com/PRQL/prql)!
  * [scrooge](https://github.com/pdet/Scrooge-McDuck)
  * [evalexpr_rhai](https://github.com/rustyconover/duckdb-evalexpr-rhai-extension)

## Quickstart

```sh
alias ducker='docker run --rm -i $([ ! -t 0 ] || echo "-t") -v $(pwd):/data -w /data flyskype2021/ducker'
```
then `ducker` gives you a [DuckDB](https://duckdb.org/) shell with the included extensions already enabled!

Test your setup with
```sh
echo "SELECT 42" | ducker
```

or get the first 5 lines of a csv file named "albums.csv", with the following PRQL query:
```sh
ducker -c 'from `albums.csv` | take 5;'
```

## Config

If there is a `.env` file in the directory that you are calling `ducker` from, then that will be read in
and added to the environment inside the container.

Furthermore, if there is a `.duckdbrc` file in the current directory, then it will be executed at startup
after have any environment variable references substituted using the `envsubst` utility.

This means that for working with files on S3, having a `.duckdbrc` file like the following in your current
directory allows you to specify your S3 credentials via a `.env` file.

```sql
set s3_endpoint='${S3_ENDPOINT}';
set s3_access_key_id='${S3_ACCESS_KEY_ID}';
set s3_secret_access_key='${S3_SECRET_ACCESS_KEY}';
set s3_use_ssl=${S3_USE_SSL};
set s3_region='${S3_REGION}';
set s3_url_style='${S3_URL_STYLE}';
```

## Examples

We can use the example from the [duckdb-prql](https://github.com/ywelsch/duckdb-prql) extension.

We start `ducker` with:

```bash
ducker
```

As PRQL does not support DDL commands, we use SQL for defining our tables:
```sql
CREATE TABLE invoices AS SELECT * FROM
  read_csv_auto('https://raw.githubusercontent.com/PRQL/prql/main/prql-compiler/tests/integration/data/chinook/invoices.csv');
CREATE TABLE customers AS SELECT * FROM
  read_csv_auto('https://raw.githubusercontent.com/PRQL/prql/main/prql-compiler/tests/integration/data/chinook/customers.csv');
```
Then we can query using PRQL:
```elm
from invoices
filter invoice_date >= @1970-01-16
derive [
  transaction_fees = 0.8,
  income = total - transaction_fees
]
filter income > 1
group customer_id (
  aggregate [
    average total,
    sum_income = sum income,
    ct = count,
  ]
)
sort [-sum_income]
take 10
join c=customers [==customer_id]
derive name = f"{c.last_name}, {c.first_name}"
select [
  c.customer_id, name, sum_income
]
```

which returns:
```
┌─────────────┬─────────────────────┬────────────┐
│ customer_id │        name         │ sum_income │
│    int64    │       varchar       │   double   │
├─────────────┼─────────────────────┼────────────┤
│           6 │ Holý, Helena        │      43.83 │
│           7 │ Gruber, Astrid      │      36.83 │
│          24 │ Ralston, Frank      │      37.83 │
│          25 │ Stevens, Victor     │      36.83 │
│          26 │ Cunningham, Richard │      41.83 │
│          28 │ Barnett, Julia      │      37.83 │
│          37 │ Zimmermann, Fynn    │      37.83 │
│          45 │ Kovács, Ladislav    │      39.83 │
│          46 │ O'Reilly, Hugh      │      39.83 │
│          57 │ Rojas, Luis         │      40.83 │
├─────────────┴─────────────────────┴────────────┤
│ 10 rows                              3 columns │
└────────────────────────────────────────────────┘
```

## Acknowledgements

This repo is adapted from https://github.com/davidgasquez/docker-duckdb.
