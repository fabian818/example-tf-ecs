module "ec2_instances" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "4.3.0"

  for_each = local.ec2_instances

  name = "${local.resource_prefix}-${local.aws_region}-${each.key}-ec2"

  ami                         = each.value.ami
  instance_type               = each.value.instance_type
  key_name                    = each.value.key_name
  vpc_security_group_ids      = each.value.vpc_security_group_ids
  subnet_id                   = each.value.subnet_id
  create_spot_instance        = each.value.create_spot_instance
  create_iam_instance_profile = true
  iam_role_use_name_prefix    = false

  tags = merge(local.default_tags, {
    Name = "${local.resource_prefix}-${local.aws_region}-${each.key}-ec2"
  })
}

resource "aws_iam_role_policy_attachment" "ssm_attach" {
  for_each = local.ec2_instances

  role       = module.ec2_instances[each.key].iam_role_name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_eip" "instance" {
  for_each = { for k, v in local.ec2_instances : k => v if !v.create_spot_instance }

  instance = module.ec2_instances[each.key].id
  vpc      = true
}

resource "aws_eip" "spot_instance" {
  for_each = { for k, v in local.ec2_instances : k => v if v.create_spot_instance }

  instance = module.ec2_instances[each.key].spot_instance_id
  vpc      = true
}