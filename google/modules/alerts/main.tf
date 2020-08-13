resource "google_monitoring_notification_channel" "email" {
  count = length(var.notification_list)
  display_name = var.notification_list[count.index].display_name
  type         = "email"
  labels = {
    email_address = var.notification_list[count.index].email
  }
}

resource "google_monitoring_alert_policy" "node_high_cpu" {
  count = length(var.notification_list) > 0 ? 1 : 0
  display_name = "Node High CPU Usage"
  combiner     = "OR"
  conditions {
    display_name = "VM Instance - CPU utilization"
    condition_threshold {
      filter = "metric.type=\"compute.googleapis.com/instance/cpu/utilization\" resource.type=\"gce_instance\""
      duration = "600s"
      comparison = "COMPARISON_GT"                  
      aggregations {
        alignment_period = "60s"
        per_series_aligner = "ALIGN_MEAN"
      }
      trigger {
        count = 0
        percent = 100      
      }
      threshold_value = 0.80
    }
  }
  notification_channels = ["${google_monitoring_notification_channel.email[0].name}"]
}

#resource "google_monitoring_dashboard" "default" {
#  dashboard_json = <<EOF
#{
#  "displayName": "Main Dashboard",
#  "gridLayout": {
#    "columns": "2",
#    "widgets": [{
#      "title": "Cluster Node - CPU %",
#      "xyChart": { 
#        "chartOptions": {
#          "mode": "COLOR"
#        },
#        "dataSets": [{
#          "legendTemplate": ""${metric.labels.instance_name}"",
#          "minAlignmentPeriod": "60s",
#          "plotType": "LINE",
#          "timeSeriesQuery": {
#            "timeSeriesFilter": {
#              "aggregation": {
#                "crossSeriesReducer": "REDUCE_MEAN",
#                  "groupByFields": [
#                    "metric.label.\"instance_name\""
#                  ],
#                  "perSeriesAligner": "ALIGN_MEAN"
#              },
#              "filter": "metric.type=\"compute.googleapis.com/instance/cpu/utilization\" resource.type=\"gce_instance\" metadata.user_labels.\"gke-${var.cluster_name}-safer-pool\"=\"\"\"",
#              "secondaryAggregation": {}
#            },
#            "unitOverride": "count"
#          }
#        }],
#        "timeshiftDuration": "0s",
#        "yAxis": {
#          "label": "y1Axis",
#          "scale": "LINEAR"
#        }
#      }
#    }]
#  }
#}
#
#EOF
#}
