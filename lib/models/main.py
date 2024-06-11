import datetime
from statistics import LinearRegression
import pandas as pd
import json
from flask import Flask, jsonify, render_template, url_for
import numpy as np
import requests
from sklearn.model_selection import train_test_split
from sklearn.ensemble import RandomForestRegressor
from sklearn.metrics import mean_absolute_error, mean_squared_error

app = Flask(__name__)

@app.route('/masterEngine')
def masterEngine():
    data = pd.read_csv('resources/CDIMeteringAuditData.csv')
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
    
    return processed_data[0]

@app.route('/recommendationEngine')
def recommendationEngine():
    response = requests.get("http://127.0.0.1:5000/masterEngine")
    data_json = response.json()

    # print(data_json.items())

    # Parse JSON data and transform it into a DataFrame
    def json_to_dataframe(data):
        records = []
        for key, value in data.items():
            org_id = key
            if key != "Org ID":
                for task_id, task_details in data[key].items():
                    task_details['Org ID'] = 1
                    task_details['Task ID'] = task_id
                    records.append(task_details)
        return pd.DataFrame(records)

    data = json_to_dataframe(data_json)

    # Debug: Print the initial few rows of data
    print("Initial data:")
    print(data.head())
    
    # Convert Start Time and End Time to datetime
    data['Start Time'] = pd.to_datetime(data['Start Time'], errors='coerce')
    data['End Time'] = pd.to_datetime(data['End Time'], errors='coerce')
    # Create new features such as duration of tasks
    data['Duration'] = (data['End Time'] - data['Start Time']).dt.total_seconds()

    # Ensure numerical columns are of the correct type
    data['Metered Value'] = pd.to_numeric(data['Metered Value'], errors='coerce')
    data['Cores Used'] = pd.to_numeric(data['Cores Used'], errors='coerce')
    data['Duration'] = pd.to_numeric(data['Duration'], errors='coerce')

    # Drop rows with missing values in essential columns
    data = data.dropna(subset=['Metered Value', 'Cores Used', 'Duration'])

    # Debug: Print the data after dropping missing values
    print("Data after dropping missing values:")
    print(data.head())

    # Convert categorical data to numeric using one-hot encoding or label encoding
    categorical_columns = ['Task Type', 'Project Name', 'Folder Name', 'Environment', 'Status']
    data = pd.get_dummies(data, columns=categorical_columns)

    # Ensure there are no string columns left
    for column in data.columns:
        if data[column].dtype == 'object':
            print(f"Column '{column}' is still a string. Converting to numeric.")
            data[column] = pd.to_numeric(data[column], errors='coerce')

    # Create additional time-based features
    data['Year'] = data['Start Time'].dt.year
    data['Month'] = data['Start Time'].dt.month

    # Group data by Org ID and Month to aggregate metered usage
    monthly_usage = data.groupby(['Org ID', 'Year', 'Month']).agg({
        'Metered Value': 'sum',
        'Cores Used': 'mean',  # Example of additional features
        'Duration': 'mean'
    }).reset_index()

    # Debug: Print the grouped monthly usage data
    print("Monthly usage data:")
    print(monthly_usage.head())

    # Check if the resulting DataFrame is empty
    if monthly_usage.empty:
        print("No data available after grouping.")
    else:
        # Define features and target
        features = monthly_usage.drop(columns=['Metered Value'])
        target = monthly_usage['Metered Value']

        # Debug: Print the features and target
        print("Features:")
        print(features.head())
        print("Target:")
        print(target.head())

        # Split the data
        try:
            X_train, X_test, y_train, y_test = train_test_split(features, target, test_size=0.2, random_state=42)

            # Check if the train or test sets are empty
            if X_train.empty or X_test.empty:
                print("Training or testing sets are empty. Adjust the split ratio or check the data.")
            else:
                # Initialize and train the model
                model = RandomForestRegressor(n_estimators=100, random_state=42)
                model.fit(X_train, y_train)

                # Make predictions
                y_pred = model.predict(X_test)

                # Evaluate the model
                mae = mean_absolute_error(y_test, y_pred)
                mse = mean_squared_error(y_test, y_pred)
                rmse = np.sqrt(mse)

                print(f'Mean Absolute Error: {mae}')
                print(f'Root Mean Squared Error: {rmse}')

                # Function to make predictions for the next month
                def predict_next_month(org_id, year, month, model, data):
                    # Get the last month data for the given org
                    last_month_data = data[(data['Org ID'] == org_id) & (data['Year'] == year) & (data['Month'] == month)]

                    if last_month_data.empty:
                        raise ValueError(f"No data found for Org ID {org_id} in {month}/{year}")

                    # Prepare the feature set for the next month
                    next_month_data = last_month_data.copy()
                    next_month_data['Month'] = (next_month_data['Month'] % 12) + 1
                    if next_month_data['Month'].iloc[0] == 1:
                        next_month_data['Year'] += 1

                    # Drop the target column and make predictions
                    next_month_data = next_month_data.drop(columns=['Metered Value'])
                    predicted_usage = model.predict(next_month_data)

                    return predicted_usage

                try:
                    predicted_usage = predict_next_month(
                        org_id=monthly_usage["Org ID"].iloc[-1], 
                        year=monthly_usage["Year"].iloc[-1], 
                        month=monthly_usage["Month"].iloc[-1], 
                        model=model, 
                        data=monthly_usage
                    )
                    return [predicted_usage[0]]
                except ValueError as e:
                    print(e)
        except ValueError as e:
            print(f"Error in train-test split: {e}")

if __name__ == '__main__':
    app.run(debug = True)