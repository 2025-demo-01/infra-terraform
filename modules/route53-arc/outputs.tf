output "panel_arn"     { value = aws_route53recoverycontrolconfig_control_panel.panel.arn }
output "primary_rc_arn"{ value = aws_route53recoverycontrolconfig_routing_control.primary.arn }
output "secondary_rc_arn"{ value = aws_route53recoverycontrolconfig_routing_control.secondary.arn }
