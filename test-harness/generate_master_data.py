import json
import uuid


# Generating Warehouse Data
dwh = []
for x in range(3):
	wh_uid = 'dwh-' + str(uuid.uuid1())
	row = '{"uid" : "' + wh_uid + '"}';
	dwh.append(row)

# Writing to warehouse.json
with open("warehouse.json", "w") as outfile:
	for x in dwh:
		outfile.write(x + "\n")



# # Generating Supplier Data
# for x in range(100):
# 	row = '{"uid" : "sup-' + str(uuid.uuid1()) + '"}';
# 	arr.append(row)

# # Writing to supplier.json
# with open("supplier.json", "w") as outfile:
# 	for x in arr:
# 		outfile.write(x + "\n")

# # Generating Warehouse Data
# arr.clear()
# for x in range(3):
# 	row = '{"uid" : "wh-' + str(uuid.uuid1()) + '"}';
# 	arr.append(row)

# # Writing to warehouse.json
# with open("warehouse.json", "w") as outfile:
# 	for x in arr:
# 		outfile.write(x + "\n")

# # Generating Zones Data
# arr.clear()
# for x in range(4):
# 	row = '{"uid" : "zone-' + str(uuid.uuid1()) + '"}';
# 	arr.append(row)

# # Writing to zone.json
# with open("zone.json", "w") as outfile:
# 	for x in arr:
# 		outfile.write(x + "\n")

# # Generating Cities Data
# arr.clear()
# for x in range(120):
# 	row = '{"uid" : "city-' + str(uuid.uuid1()) + '"}';
# 	arr.append(row)

# # Writing to city.json
# with open("city.json", "w") as outfile:
# 	for x in arr:
# 		outfile.write(x + "\n")

# # Generating Customer Data
# arr.clear()
# for x in range(10000):
# 	row = '{"uid" : "cid-' + str(uuid.uuid1()) + '"}';
# 	arr.append(row)

# # Writing to customer.json
# with open("customer.json", "w") as outfile:
# 	for x in arr:
# 		outfile.write(x + "\n")
