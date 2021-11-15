
# Current Data Stack
- Database: SQL Server
- Data preparation: SQL
- Machine Learning (training and scoring): R
- Ad-hoc data work / EDA: R
- Visualization: Tableau


# Current ML in Production
- 30 Day Inpatient Readmissions (Heat Map)
- ED/inpatient encounter in next 12 months (Risk Stratification Score)
- Appointment No-Show Risk
- Nurse Turnover Model
- Blood Transfusion Comparison


# Current Vendor Data Tool Process
For context, consider looking at project section to understand the pipelines more visually/conceptually.

For each # where it says write a query below, we write the code and put it in the vendor's tool. The tool checks if the tables in the FROM and JOINs exist and will only save if they do. It also will create the output table itself (will not have INTO keyword in the queries like they are in this repo). The vendor system will also map/parse the FROM and JOIN tables and run the queries in the appropriate order without us needing to tell it which order things should run in.

1. Write population query for the project and set to "training mode"* (output population table in EDW)
2. Write feature queries using the population table (output each as their own table)
3. Write the target query using the population table (output as it's own EDW table)
4. Write the modeling/scoring data set table using the population, feature, target table (output to table)
5. Do EDA and assess if more development work is needed on pop, features, target
6. Write training script for model development and test model performance
7. Flip pop, feature, target, modeling queries into "scoring mode"*
8. Upload model file (RData) into vendor tool
9. Write final R scoring script and upload into vendor tool
10. Run the final packaged project (pop, feature, target, modelingdata tables along with model file and R scoring script) to make sure everything will run in one smooth process

Our vendor handles all ETL (the technical parts of it), data orchestration, MLOps, compute, etc. We provide the SQL to gather all the data and the R scripts to score patients. We then have our training scripts that we keep separately

*Training and Scoring mode refer to changes in the population queries of an ML pipeline (Project 1 and 2 below) that we have to make in our vendor tool depending on what orientation we need the data in. You'll notice that the Training orientation in Project 2 is to include any discharges in a 17 month period while the Scoring orientation is to include any patients currently in the hospital. When we put our code for an ML pipeline in our vendor tool, we modify the population query this way based on the phase of the project.

# Future Data Stack Interests
- Apache Airflow (or derivative) for orchestration
    - need an orchestration system that has tracking abilities built in
        - track individual DAGs (start time, finish time, seconds/minutes it ran, etc)
        - track each pipeline (start time, finish time, seconds/minutes it ran, etc)
        - customization to track row count of output would be nice
- Apache Spark
- Azure Data Factory for incremental loading of source data
    - we have figured out the full load / query based copy data tool but need something for incremental loading (loading only what's changed in the source)
- Synapse Analytics
- Feature Stores
    - what are they?
    - how are they used?
    - what types of our pipelines can they be used for? training, scoring, tool data source?
- PowerBI


# Things we are interested to learn about to improve modularity of work and increase efficiency
Things mentioned here might benefit from looking at the project files first or in tandem.

In the Project One and Project Two folders, you'll notice that the A1c query is nearly identical between the two projects. The difference include the INTO (where the data is saved), the population used (in the CTE FROM), and the level of aggregation (PatientID for Project One and PatientEncounterID for Project Two). Otherwise, the code uses the same fields and codes to identify A1c. Same with Potassium **How do we share features across projects so if we had both of those systems in Production, we wouldn't be running (essentially) the same query twice in the same morning**

Within a project, we'll have features for labs, medications, diseases, etc that are very similar. If you go into Project One and Project Two, you'll see that the A1c and Potassium query in the same project only has one different line (except for the INTO statement) which is the CODE field that distinguishes A1c and Potassium. Our lab table in the EDW has all labs in one table so you have to query the same table each time for each lab. **How do we "group" similar features together and allow fewer queries, not having to re-run essentially the same code over and over again.**


# Data Science Workloads
Our team has 4 different type of workloads that run for our work.

**Training pipelines:** Takes data from source EDW tables, gathers features and targets, then creates a data set that can be feed into a training pipeline. Previous steps are done in SQL. EDA and modeling training are completed in R. Process done by manual kickoff of SQL query chain and manually running training R script

**Production/Scoring Pipelines:** Takes data from source EDW tables, gathers features, then creates a data set that can be fed into an already trained ML model. Previous steps done in SQL. Batch scoring completed in R. SQL query chain kickoff and R scoring script kickoff are started by vendor tool. R scoring script saves predictions back into SQL table.

**Ad-hoc / Less Complex ML Projects:** Use an R script for data manipulation. A basic SQL query might be called from R to get the raw data but manipulation is done in R (via dplyr usually). Small portion of our portfolio. If this needs to run at a certain interval, Task Scheduler on a server is used to do so. Ad-hoc will just be run as needed.

**Tool Data Sources:** Similar run process as Training and Production pipelines but without ML. This will produce a tabular dataset that can be fed into a visualization tool. SQL queries run in a certain order and create a final output table. The process might incorporate predictions from Production/Scoring pipelines if applicable. 


# Example Projects
These are the types of projects that we would need to be able to replicate in Azure that we currently do in our vendor tool or on-prem. Project 1 and 2 are projects that have different data grains and different population set-ups (1 has the same ReferenceDTS for all patients where 2 has a different one for each patient - for training mode). These examples are scaled down significantly from what is actually in production but highlight enough to give you an idea of the project/process.

**These queries use fake tables/patient data loaded into Azure SQL database.**

## Project 1
This project predicts the likelihood of an ED visit in the next 12 months for each active patient in the system. This is a scaled down version of our ED or inpatient visit in the next 12 months risk score that fuels the Care Management program at UnityPoint.

Only "active" patients get a risk score based on this prediction. We have defined an active patient as one who has visited a UPH facility in the past 12 months. We want to make sure clinicians are contacting patients who have a tie to UPH. Care Managers spend time working up and contacting patients to encourage them to enroll in the program and if they spend this time on non-active patients, it wastes their time. This active group of patients is identified by the **Population** query in the project folder.

Features used to predict the risk of ED visit are A1c and potassium labs. The **TargetEDEncounterFLG** creates a 1/0 flag for if the target (ED visit in next 12 months) happened. **ModelingData** joins all of the queries together into a data set suitable for training an ML model or feeding through an already created model for batch scoring.

Project Data Pipeline (click to view source):
    ![data pipeline](https://github.com/uphdatascience/AzureMTCProjects/blob/master/Data%20Pipeline%20New.png)
    
Project Table Examples (click to view source):
    ![data pipeline](https://github.com/uphdatascience/AzureMTCProjects/blob/master/ed%20visits%20table%20pipeline.png)
    
Project Feature/Target Date Range Diagram:
    ![date pipeline](https://github.com/uphdatascience/AzureMTCProjects/blob/master/ed%20visit%20date%20ranges.png)


## Project 2
This project predicts the likelihood of a readmission to the hospital within 30 days of discharge, a common healthcare outcomes metric. We currently have a model in production that does this. Our model in production predicts 30-day risk but also day-by-day risk within the 30 days.

Training population will be patients discharged in a specific period of time (usually between 18 months ago and up until 30 days ago) and the Production pipeline will be patients currently in the hospital. In this pared down example, A1c and potassium are features and readmission within 30 days of discharge is the target. **ModelingData** combines the population, features, and target into a data set to feed to a training pipeline or scoring script.

Project Data Pipeline (click to view source):
    ![data pipeline](https://github.com/uphdatascience/AzureMTCProjects/blob/master/Data%20Pipeline%20New.png)
    
Project Table Examples (click to view source):
    ![data pipeline](https://github.com/uphdatascience/AzureMTCProjects/blob/master/readmissions%20table%20pipeline.png)

Project Feature/Target Date Range Diagram:
    ![date pipeline](https://github.com/uphdatascience/AzureMTCProjects/blob/master/readmissions%20date%20ranges.png)

## Project 3
This is a mock data source for a tool that our users would interact with. This type of pipeline essentially gathers characteristics of patients along with some of the predictive model output (although not in this one because of simplicity's sake) to combine into a view that a clinician can make sense of. In our current tools, they aren't just given the prediction and left to piece together the rest of the picture of the patient's health. For example, working with Care Managers, we learned that they not only care about a patient's risk for adverse health outcomes (ED/inpatient encounter), they pair the prediction with whether they were in the hospital recently and whether or not they have an appointment coming up in the clinic. Certain patients may receive higher priority for enrollment based on the combination of the three data points. This pipeline allows for that data to be gathered in one data source and be fed to a BI tool.

This project would follow a similar data pipeline like Project 1 and 2 but instead of an R/Python section after the modeling data, the modeling data (or tool data source in this case) would be connected to a BI tool.


## Project 4
Sometimes we get ad-hoc work that is better completed in a language like R or Python or it needs to be updated frequently (using our vendor tool and SQL limits us in some of these cases). In these cases, we will write a script that ingests datam does manipulation, then outputs info (CSV, SQL table, etc). The data will then be picked up by a BI tool. Any scheduling will be done by Task Scheduler on a server (that is not always near-100% reliable like a VM in the cloud). This example is incredibly basic but was included because it is how a couple of projects currently work.
