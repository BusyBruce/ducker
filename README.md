[![ducker: [noun] a person or thing that ducks](ducker_definition.png)](https://www.dictionary.com/browse/ducker)

# 🦆 Ducker

Small docker image with [DuckDB](https://github.com/duckdb/duckdb) and extensions pre-installed!


The extensions included and loaded are:
  * [httpfs](https://duckdb.org/docs/extensions/httpfs.html)
  * [json](https://duckdb.org/docs/extensions/json)
  * [parquet](https://duckdb.org/docs/data/parquet)
  * [postgres_scanner](https://duckdb.org/docs/extensions/postgres_scanner)
  * [sqlite_scanner](https://duckdb.org/docs/extensions/sqlite_scanner)
  * [substrait](https://duckdb.org/docs/extensions/substrait)
  * [duckdb-prql](https://github.com/ywelsch/duckdb-prql)
    * This means `ducker` can quack SQL or [PRQL](https://github.com/PRQL/prql)!

## Quickstart

```sh
alias ducker='docker run --rm -i $([ ! -t 0 ] || echo "-t") -v $(pwd):/data -w /data duckerlabs/ducker'
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
derive db_version = s"version()";
```

which returns:
```
┌─────────────┬─────────────────────┬────────────┬────────────┐
│ customer_id │        name         │ sum_income │ db_version │
│    int64    │       varchar       │   double   │  varchar   │
├─────────────┼─────────────────────┼────────────┼────────────┤
│           6 │ Holý, Helena        │      43.83 │ v0.7.1     │
│           7 │ Gruber, Astrid      │      36.83 │ v0.7.1     │
│          24 │ Ralston, Frank      │      37.83 │ v0.7.1     │
│          25 │ Stevens, Victor     │      36.83 │ v0.7.1     │
│          26 │ Cunningham, Richard │      41.83 │ v0.7.1     │
│          28 │ Barnett, Julia      │      37.83 │ v0.7.1     │
│          37 │ Zimmermann, Fynn    │      37.83 │ v0.7.1     │
│          45 │ Kovács, Ladislav    │      39.83 │ v0.7.1     │
│          46 │ O'Reilly, Hugh      │      39.83 │ v0.7.1     │
│          57 │ Rojas, Luis         │      40.83 │ v0.7.1     │
├─────────────┴─────────────────────┴────────────┴────────────┤
│ 10 rows                                           4 columns │
└─────────────────────────────────────────────────────────────┘
```

## Acknowledgements

This repo is adapted from https://github.com/davidgasquez/docker-duckdb.
