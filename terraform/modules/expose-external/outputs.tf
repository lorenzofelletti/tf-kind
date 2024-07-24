output "service" {
  description = "Kubernetes service exposing the network"
  value = {
    name      = kubernetes_service_v1.network.metadata[0].name
    namespace = kubernetes_service_v1.network.metadata[0].namespace
    default_hostname = format(
      "%s.%s.svc.cluster.local",
      kubernetes_service_v1.network.metadata[0].name,
      kubernetes_service_v1.network.metadata[0].namespace
    )
    ports = tolist(kubernetes_service_v1.network.spec[0].port.*)
  }
}
