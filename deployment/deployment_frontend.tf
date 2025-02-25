resource "kubernetes_manifest" "deployment_frontend" {
  manifest = {
    "apiVersion" = "apps/v1"
    "kind" = "Deployment"
    "metadata" = {
      "namespace" = "default"
      "name" = "frontend"
    }
    "spec" = {
      "selector" = {
        "matchLabels" = {
          "app" = "frontend"
        }
      }
      "template" = {
        "metadata" = {
          "namespace" = "default"
          "annotations" = {
            "sidecar.istio.io/rewriteAppHTTPProbers" = "true"
          }
          "labels" = {
            "app" = "frontend"
          }
        }
        "spec" = {
          "containers" = [
            {
              "env" = [
                {
                  "name" = "PORT"
                  "value" = "8080"
                },
                {
                  "name" = "PRODUCT_CATALOG_SERVICE_ADDR"
                  "value" = "productcatalogservice:3550"
                },
                {
                  "name" = "CURRENCY_SERVICE_ADDR"
                  "value" = "currencyservice:7000"
                },
                {
                  "name" = "CART_SERVICE_ADDR"
                  "value" = "cartservice:7070"
                },
                {
                  "name" = "RECOMMENDATION_SERVICE_ADDR"
                  "value" = "recommendationservice:8080"
                },
                {
                  "name" = "SHIPPING_SERVICE_ADDR"
                  "value" = "shippingservice:50051"
                },
                {
                  "name" = "CHECKOUT_SERVICE_ADDR"
                  "value" = "checkoutservice:5050"
                },
                {
                  "name" = "AD_SERVICE_ADDR"
                  "value" = "adservice:9555"
                },
                {
                  "name" = "ENV_PLATFORM"
                  "value" = "aws"
                },
                {
                  "name" = "DISABLE_TRACING"
                  "value" = "1"
                },
                {
                  "name" = "DISABLE_PROFILER"
                  "value" = "1"
                },
              ]
              "image" = var.frontend
              "livenessProbe" = {
                "httpGet" = {
                  "httpHeaders" = [
                    {
                      "name" = "Cookie"
                      "value" = "shop_session-id=x-liveness-probe"
                    },
                  ]
                  "path" = "/_healthz"
                  "port" = 8080
                }
                "initialDelaySeconds" = 10
              }
              "name" = "server"
              "ports" = [
                {
                  "containerPort" = 8080
                },
              ]
              "readinessProbe" = {
                "httpGet" = {
                  "httpHeaders" = [
                    {
                      "name" = "Cookie"
                      "value" = "shop_session-id=x-readiness-probe"
                    },
                  ]
                  "path" = "/_healthz"
                  "port" = 8080
                }
                "initialDelaySeconds" = 10
              }
              "resources" = {
                "limits" = {
                  "cpu" = "200m"
                  "memory" = "128Mi"
                }
                "requests" = {
                  "cpu" = "100m"
                  "memory" = "64Mi"
                }
              }
            },
          ]
          "serviceAccountName" = "default"
        }
      }
    }
  }
}

resource "kubernetes_manifest" "service_frontend" {
  manifest = {
    "apiVersion" = "v1"
    "kind" = "Service"
    "metadata" = {
      "namespace" = "default"
      "name" = "frontend"
    }
    "spec" = {
      "ports" = [
        {
          "name" = "http"
          "port" = 80
          "targetPort" = 8080
        },
      ]
      "selector" = {
        "app" = "frontend"
      }
      "type" = "ClusterIP"
    }
  }
}

resource "kubernetes_manifest" "service_frontend_external" {
  manifest = {
    "apiVersion" = "v1"
    "kind" = "Service"
    "metadata" = {
      "namespace" = "default"
      "name" = "frontend-external"
    }
    "spec" = {
      "ports" = [
        {
          "name" = "http"
          "port" = 80
          "targetPort" = 8080
        },
      ]
      "selector" = {
        "app" = "frontend"
      }
      "type" = "LoadBalancer"
    }
  }
}
