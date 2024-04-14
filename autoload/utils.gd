@tool
extends Node

# Helper function to repeat a character a specified number of times
func repeat_char(character: String, count: int) -> String:
	var result = ""
	for i in range(count):
		result += character
	return result


# Helper function to manually create padding for strings
func pad_string(text: String, total_length: int) -> String:
	var result = text
	while result.length() < total_length:
		result += " "
	return result


# Function to check the structure of the dictionary
func is_nested_dictionary(dict: Dictionary) -> bool:
	for key in dict.keys():
		if dict[key] is Dictionary:
			return true
	return false


# Function to print any dictionary of dictionaries as a table
func print_dictionary(dict: Dictionary):
	var headers = []
	var col_widths = {}
	var nested = is_nested_dictionary(dict)

	# Collect headers and determine maximum column widths
	if nested:
		for outer_key in dict.keys():
			for inner_key in dict[outer_key].keys():
				if inner_key not in headers:
					headers.append(inner_key)
				var value_width = str(dict[outer_key][inner_key]).length()
				col_widths[inner_key] = max(col_widths.get(inner_key, 0), value_width)
	else:
		for key in dict.keys():
			headers.append(key)
			var value_width = str(dict[key]).length()
			col_widths[key] = max(col_widths.get(key, 0), value_width)

	# Update column widths based on header length
	for header in headers:
		col_widths[header] = max(col_widths[header], header.length())

	# Sort headers to maintain consistent order
	headers.sort()

	# Create the header row
	var header_row = "|"
	var separator_row = "|"
	for header in headers:
		var padded_header = pad_string(header, col_widths[header])
		header_row += " " + padded_header + " |"
		separator_row += repeat_char("-", col_widths[header] + 2) + "|"

	# Print the header and separator rows
	print(header_row)
	print(separator_row)

	# Print value rows
	if nested:
		for outer_key in dict.keys():
			var value_row = "|"
			for header in headers:
				var value = str(dict[outer_key].get(header, ""))
				var padded_value = pad_string(value, col_widths[header])
				value_row += " " + padded_value + " |"
			print(value_row)
	else:
		var value_row = "|"
		for header in headers:
			var value = str(dict.get(header, ""))
			var padded_value = pad_string(value, col_widths[header])
			value_row += " " + padded_value + " |"
		print(value_row)


func print_array(array: Array):
	# Create a dictionary from the array if it contains dictionaries
	var dict_to_print = {}
	var index = 0
	var is_dict_array = false

	for item in array:
		if item is Dictionary:
			dict_to_print[str(index)] = item
			index += 1
			is_dict_array = true

	if is_dict_array:
		# Use the dictionary print function if the array contains dictionaries
		print_dictionary(dict_to_print)
	else:
		# Handle arrays of non-dictionary items with proper alignment
		var max_length = 0
		for item in array:
			var item_length = str(item).length()
			if item_length > max_length:
				max_length = item_length

		for item in array:
			var padded_item = pad_string(str(item), max_length)
			print("| " + padded_item + " |")
