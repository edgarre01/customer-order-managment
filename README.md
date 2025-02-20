# Customer Order Management & External Integration Dashboard

## Overview
This project is a Salesforce-based solution that allows users to manage customer orders through a Lightning Web Component (LWC). It includes back-end logic with Apex triggers, batch jobs, and an external API integration for real-time weather data.

## Features
- **Order Management**: Create, update, and view customer orders.
- **Apex Automation**:
  - Trigger to auto-calculate the total order value.
  - Batch job to flag overdue orders.
- **External API Integration**:
  - Fetch weather information from OpenWeather API.
- **LWC Frontend**:
  - Paginated order listing.
  - Detailed order view with customer and weather details.
  - CRUD operations for orders and order items.

## Installation & Setup

### Prerequisites
- OpenWeather API Key.
- Named Credential "WeatherAPI" setup in Salesforce.

### Step 1: Deploy Metadata
1. Deploy custom objects with their fields:
   - `Customer__c`
   - `Order__c`
   - `OrderItem__c`
   - `CalloutSetting__mdt`

### Step 2: Configure Named Credential
1. Navigate to **Setup > Named Credentials**.
2. Create a named credential:
   - Label: `WeatherAPI`
   - URL: `https://api.openweathermap.org/data/2.5/weather`
   - Authentication: None (API Key handled via metadata).

### Step 3: Metadata Configuration
1. Navigate to **Setup > Custom Metadata Types**.
2. Create a new record for `CalloutSetting__mdt`:
   - DeveloperName: `WeatherApi`
   - `Endpoint__c`: `https://api.openweathermap.org/data/2.5/weather`
   - `Method__c`: `GET`
   - `Token__c`: `<YOUR_API_KEY>`

### Step 4: Deploy Apex Classes
- `OrderService.cls` - Business logic for order calculations.
- `WeatherCallout.cls` - Handles API callouts.
- `OrdersDueIdentifyBatch.cls` - Batch job for overdue orders.
- `OrderTriggerHandler.cls` - Trigger logic using `sfdc-trigger-framework`.
- `OrderItemTriggerHandler.cls` - Trigger logic using `sfdc-trigger-framework`.
- `TriggerHandler.cls` - It is (sfdc-trigger-framework)[https://github.com/kevinohara80/sfdc-trigger-framework].

### Step 5: Deploy Apex Test
- `OrderTrigger.cls` - Trigger object `Order__c`.
- `OrderItemTrigger.cls` - Trigger object `OrderItem__c`.

### Step 6: Deploy LWC
1. Deploy `orderList` component.
2. Ensure it is accessible in Lightning App Builder.

### Step 7: Deploy Tabs and Flexipages
1. Deploy Tab `Customer__c` and `Order__c`.
2. Deploy Flexipage `Order_List`.

### Step 8: Assign Permissions
1. Assign necessary object and field permissions to users.
2. Provide API callout permissions if using external services.

## How to Use
1. **Viewing Orders**: Navigate to the **Orders** tab.
2. **Creating Orders**: Click **New**, fill in details, and save.
3. **Updating Orders**: Edit an existing order.
4. **Checking Weather Data**: Orders automatically update with weather details.
5. **Batch Job Execution**: Run `OrdersDueIdentifyBatch` manually or schedule it.

## Demo
A short demo video demonstrating the functionality is included.
https://drive.google.com/file/d/19g6RPSILP0oygWYIclAIZPyN1Kd55u2e/view?usp=sharing


## Future Enhancements
- Add custom reports and dashboards.
- Implement caching for weather data.
- Enhance UI with additional filtering and sorting.


