import json
import sys

json_file_path = sys.argv[1]
execution_name = sys.argv[2]
execution_description = sys.argv[3]
machine_name = sys.argv[4]
build_name = sys.argv[5]

with open(json_file_path, "r") as read_file:
    data = json.load(read_file)

    data["launch"]["name"] = execution_name
    data["launch"]["description"] = execution_description
    data["launch"]["attributes"] = [machine_name, build_name]

with open(json_file_path, "w") as write_file:
    json.dump(data, write_file)