#baseline for the roles, policy, policy document, attach to the instance_profile
# iam role
resource "aws_iam_role" "ec2_role" {
  name = "${var.iam_prefix}-ec2-iam-role"
  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })

  # merge(base_tags, extra_tags)
  tags = merge(var.tags, {
    Name = "${var.iam_prefix}-iam-role-ju" # Adds "fluffy-uat-role-ju" as a searchable tag
    #Prefix = var.prefix          # fluffy-uat        
  })
}

# iam policy
resource "aws_iam_policy" "ec2_policy" {
  name   = "${var.iam_prefix}-ec2-iam-policy"
  policy = data.aws_iam_policy_document.ec2_iam_document_policy.json

  # merge(base_tags, extra_tags)
  tags = merge(var.tags, {
    Name = "${var.iam_prefix}-iam-ec2-policy-ju" # Adds "fluffy-uat-role-ju" as a searchable tag
    #Prefix = var.prefix          # fluffy-uat        
  })
}

# iam policy document
# aws_iam_policy_document is a special kind of data source 
# called a Logical Data Source. It doesn't fetch anything from the cloud; 
# it generates something locally within Terraform.
# we plug it in to the aws_iam_policy resource with its .json

data "aws_iam_policy_document" "ec2_iam_document_policy" {
  # ec2 Permissions
  statement {
    actions   = ["ec2:Describe*"]
    resources = ["*"]
  }
  # s3 Permissions    # in future this should be seperate iam policy too
  statement {
    effect    = "Allow"
    actions   = ["s3:ListBucket"]
    resources = ["*"]
  }

  # DynamoDB Permissions (not flexible, prefer to have sperate iam policy document for dynamodb)
  #  statement {
  #    effect = "Allow"
  #    actions = [
  #      "dynamodb:ListTables",
  #      "dynamodb:Scan",
  #      "dynamodb:GetItem", # read a specific book
  #      "dynamodb:PutItem"  # SAVE books
  #    ]
  # replace "*" with your specific table ARN for better security
  #    resources = [var.dynamodb_arn] # pass in using the module dynamodb table resource
  /*
test:
aws dynamodb list-tables --region ap-southeast-1
aws dynamodb scan --table-name ju-bookinventory --region ap-southeast-1
*/
  # }
}

#iam role attachment of the iam policy
resource "aws_iam_role_policy_attachment" "attach" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = aws_iam_policy.ec2_policy.arn
}

##ec2 instance profile, attached the role to the instance profile
# output aws_iam_instance_profile. ec2_instance_profile.name to consume in ec2.tf
resource "aws_iam_instance_profile" "ec2_instance_profile" {
  name = "${var.iam_prefix}-ec2-instance_profile"
  role = aws_iam_role.ec2_role.name
  tags = merge(var.tags, {
    Name = "${var.iam_prefix}-iam-instance-profile-ju" #     
  })
}


# dynamodb --------------------------------------------------------------------------

# dynamodb specific access for the ec2 (The "Rulebook")
data "aws_iam_policy_document" "dynamo_only_permissions" {
  statement {
    effect = "Allow"
    actions = [
      "dynamodb:Scan",
      "dynamodb:GetItem",
      "dynamodb:PutItem"
    ]
    resources = [var.dynamodb_arn] # ONLY the specific table
  }
}

# dynamodb specific policy
resource "aws_iam_policy" "dynamo_access_policy" {
  name   = "${var.iam_prefix}-dynamodb-access"
  policy = data.aws_iam_policy_document.dynamo_only_permissions.json

  # merge(base_tags, extra_tags)
  tags = merge(var.tags, {
    Name = "${var.iam_prefix}-iam-dynamo-policy-ju"
  })
}

# 
# This specifically links the DynamoDB policy to your Role
resource "aws_iam_role_policy_attachment" "attach_dynamo" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = aws_iam_policy.dynamo_access_policy.arn
}


# RDS ------------------------------------------------------------------------------------

data "aws_iam_policy_document" "secrets_read_doc" {
  statement {
    effect = "Allow"
    actions = [
      "secretsmanager:GetSecretValue",
      "secretsmanager:DescribeSecret"
    ]
    #restrict it ONLY to specific RDS secret manager for safety
    resources = [var.db_secret_arn]
  }
}

# 2. Create the Policy
resource "aws_iam_policy" "secrets_read_policy" {
  name   = "${var.iam_prefix}-secrets-read-policy"
  policy = data.aws_iam_policy_document.secrets_read_doc.json
}

# 3. Attach it to existing EC2 Role
resource "aws_iam_role_policy_attachment" "attach_secrets" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = aws_iam_policy.secrets_read_policy.arn
}

