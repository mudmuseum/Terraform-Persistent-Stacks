########################
#                      #
#      Setup Tags      #
#                      #
########################

locals {
  tags = {
    "cost-center"        = "mudmuseum"
    "mm:resource-region" = "global"
    "mm:project"         = "pipeline-build-push"
    "mm:environment"     = "persistent"
  }
}

data "aws_caller_identity" "current" {}

data "aws_region" "current-region" {}

####################################
#                                  #
# IAM Policy, Role, and Attachment #
#     for EventBridge Actions      #
#                                  #
####################################

data "aws_iam_policy_document" "iam_policy_document_eventbridge_invoke_run_command" {

  statement {
    actions     = [ "ssm:SendCommand" ]
    resources   = [ "arn:aws:ec2:${data.aws_region.current-region.name}:${data.aws_caller_identity.current.account_id}:instance/*" ]
    condition {
      test      = "StringEquals"
      variable  = "ec2:ResourceTag/*" 
      values    = [ "aws_ec2_instance" ]
    }
  }
  statement {
    actions     = [ "ssm:SendCommand" ]
    resources   = [ "arn:aws:ssm:${data.aws_region.current-region.name}:*:document/AWS-RunShellScript" ]
  }
}

module "iam_policy_eventbridge_invoke_run_command" {
  source      = "github.com/mudmuseum/terraform-modules.git//modules/iam_policy?ref=v0.2.29"

  name        = "Amazon_EventBridge_Invoke_Run_Command_506570835"
#  description = "A Policy to allow AWS to invoke Run Command through an EventBridge trigger."
  policy      = data.aws_iam_policy_document.iam_policy_document_eventbridge_invoke_run_command.json
  path        = "/service-role/"
  tags        = merge( local.tags, map("mm:resource-type", "aws_iam_policy") )
}

#############################################
#                                           #
# IAM Policy for EventBridge STS AssumeRole #
#                                           #
#############################################

data "aws_iam_policy_document" "iam_policy_document_assume_role_eventbridge_invoke_run_command" {

  statement {
    actions     = [ "sts:AssumeRole" ]
    principals {
      type        = "Service"
      identifiers = [ "events.amazonaws.com" ]
    }
  }
}

###########################################
#                                         #
# IAM Role for EventBridge SSM RunCommand #
#                                         #
###########################################

module "iam_role_eventbridge_invoke_run_command" {
  source             = "github.com/mudmuseum/terraform-modules.git//modules/iam_role?ref=v0.2.29"

  role_name          = "Amazon_EventBridge_Invoke_Run_Command_506570835"
  assume_role_policy = data.aws_iam_policy_document.iam_policy_document_assume_role_eventbridge_invoke_run_command.json
  path               = "/service-role/"

  tags               = merge( local.tags, map("mm:resource-type", "aws_iam_role") )
}

module "iam_role_policy_attachment_eventbridge_invoke_run_command" {
  source       = "github.com/mudmuseum/terraform-modules.git//modules/iam_role_policy_attachment?ref=v0.1.5"

  role_name    = module.iam_role_eventbridge_invoke_run_command.role_name
  policy_arn   = module.iam_policy_eventbridge_invoke_run_command.policy_arn
}

#########################################
#                                       #
# EventBridge Trigger on ECR Image Push #
#  Call SSM RunCommand Refresh Docker   #
#                                       #
#########################################

module "eventbridge_rule_invoke_run_command" {
  source      = "github.com/mudmuseum/terraform-modules.git//modules/eventbridge_rule?ref=v0.2.14"

  name        = "MudMuseum-Refresh-Image-on-Push-to-ECR"
  description = "Uses SSM to stop the current container and restart the container with the latest image."
#   role_arn    = module.iam_role_eventbridge_invoke_run_command.role_arn
  tags        = merge( local.tags, map("mm:resource-type", "aws_cloudwatch_event_rule") )

  pattern     = <<PATTERN
                          {
                            "source": ["aws.ecr"],
                            "detail-type": ["ECR Image Action"],
                            "detail": {
                              "action-type": ["PUSH"],
                              "result": ["SUCCESS"]
                            }
                          }
PATTERN
}

module "eventbridge_target_invoke_run_command" {
  source = "github.com/mudmuseum/terraform-modules.git//modules/eventbridge_target?ref=v0.2.29"

  target_id           = "Ida883a8cf-bbcb-4e05-ba2f-cc5cd34e117b"
  arn                 = "arn:aws:ssm:${data.aws_region.current-region.name}::document/AWS-RunShellScript"
  rule                = module.eventbridge_rule_invoke_run_command.name
  role_arn            = module.iam_role_eventbridge_invoke_run_command.role_arn

  input_paths         = { repository = "$.detail.repository-name" }
  input_template      = "{ \"commands\": [ \"docker stop <repository>\", \"docker rm <repository>\", \"/usr/local/bin/muds/docker_startup.sh <repository>\" ] }"

  run_command_targets = [ 
                          {
                            tag_key   = "tag:mm:resource-type"
                            tag_value = [ "aws_ec2_instance" ]
                          },
                          {
                            tag_key   = "mm:project"
                            tag_value = [ "mud host" ]
                          }
                        ]
}
