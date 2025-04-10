# channel-proxy

![Version: 0.2.0](https://img.shields.io/badge/Version-0.2.0-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 1.0.0](https://img.shields.io/badge/AppVersion-1.0.0-informational?style=flat-square)

A Helm chart for Channel Proxy OpenResty application

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| affinity | object | `{}` |  |
| autoscaling.behavior | object | `{}` |  |
| autoscaling.enabled | bool | `true` |  |
| autoscaling.maxReplicas | int | `5` |  |
| autoscaling.minReplicas | int | `2` |  |
| autoscaling.targetCPUUtilizationPercentage | int | `80` |  |
| autoscaling.targetMemoryUtilizationPercentage | int | `80` |  |
| deployStrategy.rollingUpdate.maxSurge | int | `2` |  |
| deployStrategy.rollingUpdate.maxUnavailable | int | `0` |  |
| deployStrategy.type | string | `"RollingUpdate"` |  |
| dnsConfig.enabled | bool | `false` |  |
| dnsConfig.ndots | int | `1` |  |
| env | list | `[]` |  |
| fullnameOverride | string | `""` |  |
| gatewayApi.annotations | object | `{}` |  |
| gatewayApi.backendPolicy.drainingTimeoutSec | int | `60` |  |
| gatewayApi.backendPolicy.timeoutSec | int | `300` |  |
| gatewayApi.enabled | bool | `false` |  |
| gatewayApi.gatewayName | string | `""` |  |
| gatewayApi.gke | bool | `false` |  |
| gatewayApi.healthCheckPolicy.checkIntervalSec | int | `10` |  |
| gatewayApi.healthCheckPolicy.healthyThreshold | int | `1` |  |
| gatewayApi.healthCheckPolicy.httpHealthCheckPath | string | `"/"` |  |
| gatewayApi.healthCheckPolicy.timeoutSec | int | `10` |  |
| gatewayApi.healthCheckPolicy.unhealthyThreshold | int | `3` |  |
| gatewayApi.hostnames | list | `[]` |  |
| image.pullPolicy | string | `"IfNotPresent"` |  |
| image.repository | string | `"public.ecr.aws/k7i3e2s7/channel-proxy:latest"` |  |
| image.tag | string | `"latest"` |  |
| ingress.annotations | object | `{}` |  |
| ingress.enabled | bool | `true` |  |
| ingress.hosts[0].host | string | `"channel-proxy.wenrix.com"` |  |
| ingress.hosts[0].paths[0].path | string | `"/"` |  |
| ingress.hosts[0].paths[0].pathType | string | `"Prefix"` |  |
| nameOverride | string | `""` |  |
| nodeSelector | object | `{}` |  |
| pdb.enabled | bool | `true` |  |
| pdb.minAvailable | int | `1` |  |
| podAnnotations | object | `{}` |  |
| podSecurityContext | object | `{}` |  |
| replicaCount | int | `1` |  |
| resources.limits.cpu | string | `"1000m"` |  |
| resources.limits.memory | string | `"1Gi"` |  |
| resources.requests.cpu | string | `"500m"` |  |
| resources.requests.memory | string | `"512Mi"` |  |
| secrets | object | `{}` |  |
| securityContext | object | `{}` |  |
| service.port | int | `8080` |  |
| service.type | string | `"ClusterIP"` |  |
| serviceAccount.annotations | object | `{}` |  |
| serviceAccount.automountToken | bool | `false` |  |
| serviceAccount.create | bool | `false` |  |
| serviceAccount.name | string | `""` |  |
| serviceMonitor.enabled | bool | `false` |  |
| serviceMonitor.interval | string | `"30s"` |  |
| serviceMonitor.labels | object | `{}` |  |
| serviceMonitor.path | string | `"/metrics"` |  |
| terminationGracePeriodSeconds | int | `30` |  |

