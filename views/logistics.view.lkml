# The name of this view in Looker is "Logistics"
view: logistics {
  # The sql_table_name parameter indicates the underlying database table
  # to be used for all fields in this view.
  sql_table_name: `vitaming.logistics`
    ;;
  # No primary key is defined for this view. In order to join this view in an Explore,
  # define primary_key: yes on a dimension that has no repeated values.

  # Here's what a typical dimension looks like in LookML.
  # A dimension is a groupable field that can be used to filter query results.
  # This dimension will be called "Customer ID" in Explore.

  dimension: customer_id {
    type: string
    sql: ${TABLE}.customer_id ;;
  }

  dimension: customer_location {
    type: number
    sql: ${TABLE}.customer_location ;;
  }

  dimension: item_id {
    type: number
    sql: ${TABLE}.item_id ;;
  }

  dimension: local_warehouse {
    type: number
    sql: ${TABLE}.local_warehouse ;;
  }

  dimension: package_id {
    type: string
    sql: ${TABLE}.package_id ;;
  }

  dimension: price {
    type: number
    sql: ${TABLE}.price ;;
  }

  # A measure is a field that uses a SQL aggregate function. Here are defined sum and average
  # measures for this dimension, but you can also add measures of many different aggregates.
  # Click on the type parameter to see all the options in the Quick Help panel on the right.

  measure: total_price {
    type: sum
    sql: ${price} ;;
  }

  measure: average_price {
    type: average
    sql: ${price} ;;
  }

  dimension: status {
    type: string
    sql: ${TABLE}.status ;;
  }

  dimension: supplier_id {
    type: number
    # hidden: yes
    sql: ${TABLE}.supplier_id ;;
  }

  # Dates and timestamps can be represented in Looker using a dimension group of type: time.
  # Looker converts dates and timestamps to the specified timeframes within the dimension group.

  dimension_group: transaction {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: ${TABLE}.transaction_time ;;
  }

  dimension: warehouse {
    type: number
    sql: ${TABLE}.warehouse ;;
  }

  measure: total_orders  {
    type: count_distinct
    sql: ${package_id};;
  }

  measure: total_sales {
    type: sum
    sql: ${price} ;;
    value_format: "#,,M"
  }

  measure: avg_sales_price {
    type: number
    sql: ${total_price}/${total_orders} ;;
    value_format: "$0.00"
  }
}
