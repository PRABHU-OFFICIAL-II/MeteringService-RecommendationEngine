import pandas as pd
import json
from flask import Flask, render_template, url_for

app = Flask(__name__)

@app.route('/masterEngine')
def masterEngine():
    data = pd.read_csv('C:/Users/ppenthoi/OneDrive - Informatica/Documents/IDMC/Project INFA/IPU Recommendation/CDIMeteringAuditData.csv')
    attributes_to_drop = ['Task Object Name', 'Audit Time', 'OBM Task Time(s)']
    data_cleaned = data.drop(columns=attributes_to_drop)
    print(data_cleaned)

    task_attributes = ['Task Name', 'Task Type', 'Task Run ID', 'Project Name', 'Folder Name', 
                    'Environment ID', 'Environment', 'Cores Used', 
                    'Start Time', 'End Time', 'Status', 'Metered Value']

    json_data = []

    for org_id, group_data in data.groupby('Org ID'):

        tasks = {}
        for _, row in group_data.iterrows():
            task = {}
            for attr in task_attributes:
                task[attr] = row[attr]

            tasks[row['Task ID']] = task

        org_json = {
            "Org ID": org_id,
            "Tasks": tasks
        }

        json_data.append(org_json)

    with open('output.json', 'w') as json_file:
        json.dump(json_data, json_file, indent=4)
    
    print("JSON data saved to 'output.json' file.")

    processed_data = []

    with open('output.json') as output_json:
        processed_data = json.load(output_json)

    # Handling the nan values in the Folder Name.
    for i in processed_data[0]["Tasks"]:

        # Added test data for the IPU consumption field.
        processed_data[0]["Tasks"][i]["IPU Consumed"] = processed_data[0]["Tasks"][i]["Task Run ID"] * processed_data[0]["Tasks"][i]["Metered Value"]

        # print(processed_data[0]["Tasks"][i]["Folder Name"], end="\n")
        if type(processed_data[0]["Tasks"][i]["Folder Name"]) != str:
            processed_data[0]["Tasks"][i]["Folder Name"] = "Null"

    # Dumping the handled data into the output.json
    with open('output.json', 'w') as json_file:
        json.dump(processed_data, json_file, indent=4)

    # return render_template('index.html', data = processed_data)   
    return processed_data[0]


if __name__ == '__main__':
    app.run(debug = True)