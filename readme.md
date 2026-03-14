This repository manages the automated deployment of the Fluffy application environment using Terraform modules. 
It includes a secure VPC, IAM roles with least-privilege access, EC2 compute instances, and a DynamoDB book inventory.

.
├── main.tf              # Entry point: Connects all modules
├── locals.tf            # Common naming and tagging logic
├── variables.tf         # Global input definitions
├── outputs.tf           # Root level outputs
├── README.md            # The manual you just created
├── vars/
│   └── uat.tfvars       # Environment-specific values
├── backend-config/
│   └── uat.config       # S3 Remote State & Locking config
├── diagrams/            # <--- THE NEW FOLDER
│   ├── architecture.png # Visual map of VPC, Subnets, and Resources
│   └── iam_flow.drawio  # Editable source file for your diagrams
└── modules/
    ├── vpc/
    │   ├── main.tf
    │   ├── variables.tf
    │   └── outputs.tf
    ├── iam/
    │   ├── main.tf
    │   ├── variables.tf
    │   └── outputs.tf
    ├── ec2/
    │   ├── main.tf
    │   ├── variables.tf
    │   ├── data.tf
    │   └── outputs.tf
    └── dynamodb/
        ├── main.tf
        ├── variables.tf
        └── outputs.tf

Usage Instructions:

1. How to Initialize (Connecting to S3/Backend)
You don't just run terraform init. You tell it which backend config to use:

terraform init -backend-config=backend-config/uat.conf

2. How to Plan/Apply (Using your Vars)
You tell Terraform which "flavor" of variables to use:

terraform plan -var-file=vars/uat.tfvars
terraform apply -auto-approve -var-file=vars/uat.tfvars

this is a "Power User" Setup
Safety: By putting the state file in a separate bucket with encrypt = true and using dynamodb_table for locking, 
you prevent two people from breaking the infrastructure at the same time.

Scalability: If you need a "Production" environment next week, 
you simply create vars/prod.tfvars and backend-config/prod.config. 

Project Structure & Module Breakdown:
Root Configuration
- main.tf: The Switchboard. Calls all modules and handles the "Baton Pass" (data flow).
- locals.tf: Logic for environment prefixes (e.g., fluffy-uat) and common tags.
- variables.tf: Global variable definitions (region, project name).
- outputs.tf: Final results (Public IPs, DynamoDB Table Names) displayed in the terminal.
- vars/uat.tfvars: Specific values for the UAT environment.
- backend-config/uat.config: S3 bucket and DynamoDB locking settings for Remote State.

+-----------------------------------------------------------------------------------------------------------------+
|Module      | Files Included                  | Responsibility                                                   |
|------------|---------------------------------|------------------------------------------------------------------|   
|VPC         | main.tf, vars.tf, outputs.tf    | Creates the IGW, Public Subnets, and Route Tables.               |
|IAM         | main.tf, vars.tf, outputs.tf    | Defines the EC2 Role, Instance Profile, and S3/DynamoDB policies.|
|EC2         | main.tf, vars.tf, ... data.tf   | Provisions Ubuntu instances and defines SG rules.                |
|DynamoDB    | main.tf, vars.tf, outputs.tf    | Creates the NoSQL table and seed data.                           |
+-----------------------------------------------------------------------------------------------------------------+

---------

+----------------+---------------------------+--------------------+-------------------------------------------+
| SOURCE MODULE  | OUTPUT ATTRIBUTE          | DESTINATION MODULE | PURPOSE                                   |
+----------------+---------------------------+--------------------+-------------------------------------------+
| VPC            | vpc_id                    | EC2 & RDS          | Attaches Security Groups to the VPC.      |
+----------------+---------------------------+--------------------+-------------------------------------------+
| VPC            | public_subnet_ids         | EC2                | Deploys instances into public subnets.    |
+----------------+---------------------------+--------------------+-------------------------------------------+
| VPC            | private_subnet_ids        | RDS                | Isolates the database in private subnets. |
+----------------+---------------------------+--------------------+-------------------------------------------+
| DynamoDB       | dynamodb_arn              | IAM                | Grants access to the Book table.          |
+----------------+---------------------------+--------------------+-------------------------------------------+
| RDS            | db_secret_arn             | IAM                | Allows EC2 to read the DB password.       |
+----------------+---------------------------+--------------------+-------------------------------------------+
| EC2            | ec2_sgp_id                | RDS                | Allows DB inbound traffic from Web tier.  |
+----------------+---------------------------+--------------------+-------------------------------------------+
| IAM            | ec2_instance_profile_name | EC2                | Attaches Identity/Perms to the instance.  |
+----------------+---------------------------+--------------------+-------------------------------------------+

The "Baton Pass" (Cross-Module Dependency)
Understanding how the modules talk to each other is key to troubleshooting:
VPC → EC2: The VPC module outputs public_subnet_ids, which the EC2 module uses to place instances in its subnets (public/private)
DynamoDB → IAM: The DynamoDB module outputs the table_arn. The IAM module receives this to write a specific policy allowing the EC2 to access only that table.
IAM → EC2: The IAM module outputs the instance_profile_name. The EC2 module uses this to attach the identity to the virtual server.
Security Highlights
Security Groups: Inbound SSH (Port 22) is open; Outbound is unrestricted to allow curl and apt updates.
IAM Policy: EC2 instances use a Resource-Restricted Policy. They can only perform Scan and PutItem on the specific ARN of the book_inventory table.
State Locking: Prevents state corruption by using DynamoDB to lock the state file during updates.

Database Reference:

dynamo: -----------
Table Name: ${prefix}-bookinventory
Primary Key: ISBN (Partition) / Genre (Sort)
Billing: On-Demand (PAY_PER_REQUEST)

rds: ----------------
Database Layer: 1x PostgreSQL instance running in a Private Subnet. The Subnet Group spans 2 Availability Zones to allow for future failover/redundancy.

rds port need not to be open cos ec2 sgp is allow as the inbound

How to understand the "rds data Flow"
Terraform runs and creates a random string.
RDS is created using that string as its master password.
Secrets Manager stores that string (and the DB host address) so you don't have to remember it.
EC2 (using the IAM role we built) asks Secrets Manager for that value when you run your connection script.

VPC to RDS: Added private_subnet_ids. This is a critical distinction from the EC2 flow.

RDS to IAM: Added the db_secret_arn pass. Without this "baton," your IAM policy would be too broad (security risk) or wouldn't work at all.

EC2 to RDS: Added the Security Group pass. This is what allows your RDS to say, "I don't care if the port is 5432, I only talk to my friend the EC2."

Troubleshooting: ----------
EC2 can't reach Internet? Check the VPC module's Route Table for the 0.0.0.0/0 route to the IGW. SGP also must allow inbound/ outbound (to download/fetch installer)
Access Denied on S3/DynamoDB? Ensure the dynamodb_arn variable in the IAM module is not empty.


test: ---------------------------------------------------------------------------------------------------------

--- access to ec2 stuffs
aws ec2 describe-instances
aws s3 ls                   # this will fail because this command is equivalent to have the s3:ListAllBucket, Not s3:ListBucket
aws s3api create-bucket \   # best practice, terraform should create bucket, no perm given to ec2
   --bucket yourBucketName \
   --region yourRegion -- \
   create-bucket-configuration LocationConstraint=yourRegion

-- access to dynamo
aws dynamodb list-tables   # will not work cos the permission is scope to read ju-bookinventory
aws dynamodb scan --table-name fluffy-uat-ju-bookinventory  #ok 
aws dynamodb delete-table --table-name fluffy-uat-ju-bookinventory #no permission

--- access to rds
--- once ec2 instance connect, ec2 must be able to fetch secret value 
--- login to the postgres

SSH'd into your EC2, run this single block. It fetches the secret, extracts the password, and logs you into the database in one go:

Install the tools we need
sudo apt update && sudo apt install -y postgresql-client jq

Fetch secret, parse it, and connect
export DB_JSON=$(aws secretsmanager get-secret-value --secret-id fluffy-uat-db-password-ju --region ap-southeast-1 --query 'SecretString' --output text)

Extract pieces using jq
DB_PASS=$(echo $DB_JSON | jq -r .password)
DB_HOST=$(echo $DB_JSON | jq -r .host)
DB_USER=$(echo $DB_JSON | jq -r .username)

Connect! (It will ask for the password, which you now have in $DB_PASS)
PGPASSWORD=$DB_PASS psql -h $DB_HOST -U $DB_USER -d bookdb
What is jq doing?
jq -r .password: The -r stands for "raw." It strips away the quotation marks around the password so the database client can read it as a pure string.

.password: This tells jq to look specifically for the key named "password" inside that JSON object.

Why this is the "Right" Way
No Clipboard Leaks: You never have to copy the password to your computer's clipboard, which is a common way passwords get stolen.

Speed: If you destroy and recreate your RDS (which changes the endpoint URL and password), this script still works without you changing a single line. It always finds the latest "truth" from Secrets Manager.


FOLLOW UP:

*
resource secretmanager that is define module/rds/secret.tf can be sepreated as module/secret/main.tf

*
│ Error: creating RDS DB Instance (fluffy-uat-db-pgres-ju): operation error RDS: CreateDBInstance, https response error StatusCode: 400, RequestID: 29b67683-18bf-46fa-93ea-405e2ab1cbd0, api error InvalidParameterCombination: Cannot find version 16.1 for postgres
│
│   with module.rds.aws_db_instance.postgres,
│   on modules/rds/main.tf line 28, in resource "aws_db_instance" "postgres":
│   28: resource "aws_db_instance" "postgres"