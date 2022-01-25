locals {
  # Merge defaults and per-group values to make code cleaner
  node_groups_expanded = { for k, v in var.node_groups : k => merge(
    {
      desired_capacity        = var.workers_group_defaults["asg_desired_capacity"]
      iam_role_arn            = var.default_iam_role_arn
      instance_types          = [var.workers_group_defaults["instance_type"]]
      key_name                = var.workers_group_defaults["key_name"]
      launch_template_id      = var.workers_group_defaults["launch_template_id"]
      launch_template_version = var.workers_group_defaults["launch_template_version"]
      max_capacity            = var.workers_group_defaults["asg_max_size"]
      min_capacity            = var.workers_group_defaults["asg_min_size"]
      subnets                 = var.workers_group_defaults["subnets"]
      labels = merge(
        lookup(var.node_groups_defaults, "k8s_labels", {}),
        lookup(var.node_groups[k], "k8s_labels", {})
      )
      taints = concat(
        lookup(var.node_groups_defaults, "k8s_taints", []),
        lookup(var.node_groups[k], "k8s_taints", [])
      )
    },
    var.node_groups_defaults,
    v,
  ) if var.create_eks }

  nodegroup_labels = { for obj in flatten([
    for name, attr in local.node_groups_expanded : [
      for label, value in attr.labels : { pool = name, key = label, value = value }
    ]
  ]) : format("%s/%s", obj.pool, obj.key) => obj }

  nodegroup_taints = { for obj in flatten([
    for name, attr in local.node_groups_expanded : [
      for taint in attr.taints : { pool = name, key = taint.key, value = taint.value, effect = taint.effect }
    ]
  ]) : format("%s/%s", obj.pool, obj.key) => obj }
}
