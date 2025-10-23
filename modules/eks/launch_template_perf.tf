data "template_cloudinit_config" "perf_user_data" {
  base64_encode = true
  gzip          = false

  part {
    content_type = "text/x-shellscript"
    content      = <<-EOT
      #!/bin/bash
      echo 'KUBELET_EXTRA_ARGS="--cpu-manager-policy=static --topology-manager-policy=single-numa-node --system-reserved=cpu=500m,memory=1Gi --kube-reserved=cpu=500m,memory=1Gi"' >> /etc/sysconfig/kubelet   # [ADDED]
      systemctl daemon-reload && systemctl restart kubelet
    EOT
  }
}

resource "aws_launch_template" "perf" {
  name_prefix   = "eks-perf-"
  image_id      = var.worker_ami_id
  instance_type = "c6i.4xlarge"
  user_data     = data.template_cloudinit_config.perf_user_data.rendered
  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "eks-perf"
    }
  }
}
