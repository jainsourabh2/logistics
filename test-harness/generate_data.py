import uuid
import time
import random
import csv
import json
import requests

url = 'http://35.200.173.88:8001/api/orders/create'

STATUS = (
    'order_placed', 'supplier_checkout', 'warehouse_checkin', 'warehouse_checkout', 'local_warehouse_checkin', 'local_warehouse_checkout', 'order_delivered'
)

def read_csv_into_array():
	global suppliers_warehouse
	global suppliers_local_warehouse
	suppliers_warehouse = []


	with open('./data/suppliers.csv') as csv_file:
	    csv_reader = csv.reader(csv_file, delimiter=',')
	    line_count = 0
	    for row in csv_reader:
	        if line_count == 0:
	            suppliers_warehouse.append(0)
	            line_count += 1
	        else:
	        	suppliers_warehouse.append(row[13])
	        	line_count += 1
		
read_csv_into_array()

#print(suppliers_warehouse[8])

for x in range(2):
	time.sleep(1)
	order = {}
	customer_id = str(uuid.uuid1())
	item_id = random.randint(1,500)
	transaction_time = int(time.time() * 1000)
	supplier_loc = random.randint(1,1019) # Update the maximum number from supplier list.
	supplier_code_state = suppliers_warehouse[supplier_loc]
	package_generated_loc = random.randint(1,1019) # Update the maximum number from supplier list.
	package_generated_state = suppliers_warehouse[package_generated_loc]
	package_id = str(supplier_loc) + "#" +str(uuid.uuid1())	
	order_status_generation = random.randint(1,7)
	supplier_pickup_hours = random.randint(48,120)

	warehouse_checkin_hours_different_state = random.randint(8,24)
	warehouse_checkout_hours_different_state = random.randint(2,6)
	local_warehouse_checkin_hours_different_state = random.randint(24,96)
	local_warehouse_checkout_hours_different_state = random.randint(2,6)


	local_warehouse_checkin_hours_same_state = random.randint(8,24)
	local_warehouse_checkout_hours_same_state = random.randint(2,6)
	order_delivered_hours = random.randint(8,24)

	print ("order no ##### - ",x)

	order["package_id"] = package_id
	order['customer_id'] = customer_id
	order['supplier_id'] = supplier_loc
	order['item_id'] = item_id
	order['customer_location']  = package_generated_loc
	order['transaction_time'] = transaction_time
	order['status'] = 'order_placed'
	#Make API Call for order_paced status
	data_json= json.dumps(order)
	response = requests.post(url, data=data_json, headers={"Content-Type": "application/json"})

	supplier_checkout_timestamp = (transaction_time + ((supplier_pickup_hours * 60 * 60) * 1000))
	order['transaction_time'] = supplier_checkout_timestamp
	order['status'] = 'supplier_checkout'
	#Make API Call for supplier_checkout status
	data_json= json.dumps(order)
	response = requests.post(url, data=data_json, headers={"Content-Type": "application/json"})

	if supplier_code_state == package_generated_state:
		local_warehouse_checkin_timestamp = (supplier_checkout_timestamp + ((local_warehouse_checkin_hours_same_state * 60 * 60) * 1000))
		order['transaction_time'] = local_warehouse_checkin_timestamp
		order['local_warehouse'] = supplier_code_state
		order['status'] = 'local_warehouse_checkin'
		#Make API Call for local_warehouse_checkin status
		data_json= json.dumps(order)
		response = requests.post(url, data=data_json, headers={"Content-Type": "application/json"})

		local_warehouse_checkout_timestamp = (local_warehouse_checkin_timestamp + ((local_warehouse_checkout_hours_same_state * 60 * 60) * 1000))
		order['transaction_time'] = local_warehouse_checkout_timestamp
		order['local_warehouse'] = supplier_code_state
		order['status'] = 'local_warehouse_checkout'
		#Make API Call for local_warehouse_checkout status
		data_json= json.dumps(order)
		response = requests.post(url, data=data_json, headers={"Content-Type": "application/json"})

		order_delivered_timestamp = (local_warehouse_checkout_timestamp + ((order_delivered_hours * 60 * 60) * 1000))
		order['transaction_time'] = order_delivered_timestamp
		order['local_warehouse'] = supplier_code_state
		order['status'] = 'order_delivered'
		#Make API Call for order_delivered status
		data_json= json.dumps(order)
		response = requests.post(url, data=data_json, headers={"Content-Type": "application/json"})

		print("Package to be delivered in the same state")
	else:

		warehouse_checkin_timestamp = (supplier_checkout_timestamp + ((warehouse_checkin_hours_different_state * 60 * 60) * 1000))
		order['transaction_time'] = warehouse_checkin_timestamp
		order['warehouse'] = supplier_code_state
		order['status'] = 'warehouse_checkin'
		#Make API Call for warehouse_checkin status
		data_json= json.dumps(order)
		response = requests.post(url, data=data_json, headers={"Content-Type": "application/json"})

		warehouse_checkout_timestamp = (warehouse_checkin_timestamp + ((warehouse_checkout_hours_different_state * 60 * 60) * 1000))
		order['transaction_time'] = warehouse_checkout_timestamp
		order['warehouse'] = supplier_code_state
		order['status'] = 'warehouse_checkout'
		#Make API Call for warehouse_checkout status
		data_json= json.dumps(order)
		response = requests.post(url, data=data_json, headers={"Content-Type": "application/json"})

		local_warehouse_checkin_timestamp = (warehouse_checkout_timestamp + ((local_warehouse_checkin_hours_different_state * 60 * 60) * 1000))
		order['transaction_time'] = local_warehouse_checkin_timestamp
		order['local_warehouse'] = package_generated_state
		order['status'] = 'local_warehouse_checkin'
		#Make API Call for local_warehouse_checkin status
		data_json= json.dumps(order)
		response = requests.post(url, data=data_json, headers={"Content-Type": "application/json"})

		local_warehouse_checkout_timestamp = (local_warehouse_checkin_timestamp + ((local_warehouse_checkout_hours_different_state * 60 * 60) * 1000))
		order['transaction_time'] = local_warehouse_checkout_timestamp
		order['local_warehouse'] = package_generated_state
		order['status'] = 'local_warehouse_checkout'
		#Make API Call for local_warehouse_checkout status
		data_json= json.dumps(order)
		response = requests.post(url, data=data_json, headers={"Content-Type": "application/json"})

		order_delivered_timestamp = (local_warehouse_checkout_timestamp + ((order_delivered_hours * 60 * 60) * 1000))
		order['transaction_time'] = order_delivered_timestamp
		order['local_warehouse'] = package_generated_state
		order['status'] = 'order_delivered'
		#Make API Call for order_delivered status
		data_json= json.dumps(order)
		response = requests.post(url, data=data_json, headers={"Content-Type": "application/json"})

		print("Package to be delivered in a different state")