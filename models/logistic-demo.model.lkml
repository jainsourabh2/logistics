# Define the database connection to be used for this model.
connection: "logistic-demo"

# include all the views
include: "/views/**/*.view"

# Datagroups define a caching policy for an Explore. To learn more,
# use the Quick Help panel on the right to see documentation.

datagroup: logistic-demo_default_datagroup {
  # sql_trigger: SELECT MAX(id) FROM etl_log;;
  max_cache_age: "1 hour"
}

persist_with: logistic-demo_default_datagroup

# Explores allow you to join together different views (database tables) based on the
# relationships between fields. By joining a view into an Explore, you make those
# fields available to users for data analysis.
# Explores should be purpose-built for specific use cases.

# To see the Explore you’re building, navigate to the Explore menu and select an Explore under "Logistic-demo"

explore: logistics {
  join: suppliers {
    type: inner
    sql_on: ${logistics.supplier_id} = ${suppliers.code} ;;
    relationship: many_to_one
  }

  join: customers {
    view_label: "Customers_Location"
    type: inner
    sql_on: ${logistics.customer_id} = ${customers.code} ;;
    relationship: many_to_one
  }

  join: warehouse {
    view_label: "Warehouse"
    type: inner
    sql_on: ${logistics.warehouse} = ${warehouse.code} ;;
    relationship: many_to_one
  }

  join: warehouse_local {
    view_label: "Warehouse Local"
    type: inner
    sql_on: ${logistics.local_warehouse} = ${warehouse_local.code} ;;
    relationship: many_to_one
  }
}

# To create more sophisticated Explores that involve multiple views, you can use the join parameter.
# Typically, join parameters require that you define the join type, join relationship, and a sql_on clause.
# Each joined view also needs to define a primary key.

explore: suppliers {}
explore: customers {}
