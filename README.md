# Metered Usage Recommendation System

This project is a machine learning system designed to predict and recommend the metered usage for the next month for an organization based on historical usage data.

## Table of Contents

- [Introduction](#introduction)
- [Features](#features)
- [Requirements](#requirements)
- [Installation](#installation)
- [Usage](#usage)
- [Data Description](#data-description)
- [Model Training](#model-training)
- [Prediction](#prediction)
- [Evaluation](#evaluation)
- [Contributing](#contributing)
- [License](#license)

## Introduction

The Metered Usage Recommendation System aims to help organizations predict their future metered usage. This can be useful for budgeting, resource planning, and optimizing resource allocation.

## Features

- **Data Preprocessing**: Handles missing values and encodes categorical variables.
- **Feature Engineering**: Creates additional time-based features.
- **Model Training**: Utilizes Random Forest Regressor to train on historical data.
- **Prediction**: Predicts the next month's metered usage for an organization.
- **Evaluation**: Evaluates the model performance using MAE and RMSE.

## Requirements

Ensure you have a `requirements.txt` file in your repository to list the necessary dependencies. Here's an example:

```txt
pandas
numpy
scikit-learn
matplotlib
```

## Installation

1. Clone the repository:
    ```bash
    git clone https://github.com/your-username/metered-usage-recommendation.git
    cd metered-usage-recommendation
    ```

2. Create and activate a virtual environment:
    ```bash
    python -m venv venv
    source venv/bin/activate  # On Windows use `venv\Scripts\activate`
    ```

3. Install the required packages:
    ```bash
    pip install -r requirements.txt
    ```

## Usage

1. Ensure your dataset is in CSV format and located in the project directory.

2. Update the path to your dataset in the script:
    ```python
    data = pd.read_csv('path_to_your_dataset.csv')
    ```

3. Run the script to preprocess data, train the model, and make predictions:
    ```python
    python main.py
    ```
4. It will open a channel and create a server in the Flask, from which we can access the
   ```txt
    /masterEngine -> To access the JSON data {Org and Task Specific}
    /recommendationEngine -> To access the predicted next month value
   ```
5. Flash Server will be running on the localhost:5000 or 127.0.0.1:5000
   ```python
   127.0.0.1:5000/masterEngine
   127.0.0.1:5000/recommendationEngine
   ```

## Data Description

The dataset should contain the following fields:

- `Task ID`
- `Task Name`
- `Task Object Name`
- `Task Type`
- `Task Run ID`
- `Project Name`
- `Folder Name`
- `Org ID`
- `Environment ID`
- `Environment`
- `Cores Used`
- `Start Time`
- `End Time`
- `Status`
- `Metered Value`
- `Audit Time`
- `OBM Task Time(s)`

## Model Training

The model is trained using a Random Forest Regressor. Key steps include:

- Preprocessing: Converting timestamps, encoding categorical variables, handling missing values.
- Feature Engineering: Creating features such as task duration and monthly aggregation.
- Splitting Data: Dividing the dataset into training and testing sets.
- Training: Fitting the Random Forest model to the training data.

## Prediction

To make predictions for the next month's metered usage for a specific organization:

```python
predicted_usage = predict_next_month(org_id=1, year=2023, month=5, model=model, data=monthly_usage)
print(predicted_usage)
```
This will output the predicted metered usage for the specified organization in the next month.

## Evaluation

The model's performance is evaluated using metrics such as Mean Absolute Error (MAE) and Root Mean Square Error (RMSE).

## Contributing

Pull requests are welcome. For major changes, please open an issue first to discuss what you would like to change.

