terraform {
  required_version = ">= 1.0.0"

  required_providers {
    minio = {
      source  = "aminueza/minio"
      version = ">= 2.4.0"
    }
    logic = {
      source  = "logicorg/logic"
      version = ">= 0.1.0"
    }
  }
}
