#PArtitioned by hour on transaction_time column and clustered by supplier_id,local_warehouse and warehouse

[
  {
    "mode": "NULLABLE",
    "name": "status",
    "type": "STRING"
  },
  {
    "mode": "NULLABLE",
    "name": "transaction_time",
    "type": "TIMESTAMP"
  },
  {
    "mode": "NULLABLE",
    "name": "item_id",
    "type": "INTEGER"
  },
  {
    "mode": "NULLABLE",
    "name": "customer_id",
    "type": "STRING"
  },
  {
    "mode": "NULLABLE",
    "name": "local_warehouse",
    "type": "INTEGER"
  },
  {
    "mode": "NULLABLE",
    "name": "customer_location",
    "type": "INTEGER"
  },
  {
    "mode": "NULLABLE",
    "name": "warehouse",
    "type": "INTEGER"
  },
  {
    "mode": "NULLABLE",
    "name": "supplier_id",
    "type": "INTEGER"
  },
  {
    "mode": "NULLABLE",
    "name": "package_id",
    "type": "STRING"
  }
]