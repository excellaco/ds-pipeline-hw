# ds-pipeline-hw

THIS IS NOT A COMPLETD FRAMEWORK , THE GOAL IS TO CREATE A WORKING SAMPLE PIPELINE USING GITHUB , JENKINS TO DEPLOY TO AWS 
TO USE DATA LAKE, GLUE, LAKE FORMATION , ATHENA 

LISTED BELOW ARE THE DIRECTORY STRUCTURE 

data science pipeline with glue and athena 
data-science-hello-world/
├── infra/                  # Terraform 
│   ├── modules/
│   │   ├── data_lake/      # All Data Lake components
│   │   │   ├── glue.tf     # Crawlers, Jobs, Databases
│   │   │   ├── lf.tf       # Lake Formation permissions
│   │   │   └── athena.tf   # Workgroups/queries
│   │   ├── compute/
│   │   │   ├── ec2.tf      # EC2 instances + SG
│   │   │   └── lambda.tf   # Lambda functions
│   │   └── networking/
│   │       └── vpc.tf      # VPC for EC2/Glue
│   ├── main.tf             # Core configuration
│   ├── outputs.tf          # Output references
│   └── variables.tf        # Input variables
│
├── src/
│   ├── lambda/
│   │   └── data_processor/
│   │       ├── main.py      # Lambda handler
│   │       └── lf_helper.py # Lake Formation client
│   ├── glue/
│   │   ├── etl_job/
│   │   │   ├── main.py      # PySpark script
│   │   │   └── lf_utils.py  # Temp credential helper
│   │   └── crawlers/        # JSON configs (optional)
│   ├── athena/
│   │   └── queries/         # SQL files
│   └── data_lake/           # Data zone definitions
│       ├── raw/             # Sample raw data structure
│       └── processed/       # Processed data examples
│
├── scripts/
│   ├── deploy.sh           # terraform apply wrapper
│   └── lf_register.sh      # Lake Formation registration
│
└── Jenkinsfile             # CI/CD pipeline