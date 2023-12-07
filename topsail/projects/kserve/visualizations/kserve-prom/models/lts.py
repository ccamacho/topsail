from __future__ import annotations

from typing import Any, List, Optional

from pydantic import BaseModel, Field

import matrix_benchmarking.models as matbench_models

class GpuMetadata(matbench_models.ExclusiveModel):
    product: str
    memory: float
    count: int


class Metadata(matbench_models.Metadata):
    presets: List[str]
    config: Any
    gpus: List[GpuMetadata]


class Metrics(matbench_models.ExclusiveModel):
    kserve_container_cpu_usage: matbench_models.PrometheusValues = \
        Field(..., alias="sutest__container_cpu__namespace=watsonx.*_container=kserve-container")
    kserve_container_memory_usage: matbench_models.PrometheusValues = \
        Field(..., alias="sutest__container_memory_usage_bytes__namespace=watsonx.*_container=kserve-container")
    gpu_memory_used: matbench_models.PrometheusValues = Field(..., alias="GPU memory used")
    gpu_active_computes: matbench_models.PrometheusValues = Field(..., alias="GPU active computes")

    rhoai_mem_footprint_core_request: matbench_models.PrometheusValues = Field(..., alias="redhat-ods-.* memory request")
    rhoai_mem_footprint_core_limit: matbench_models.PrometheusValues = Field(..., alias="redhat-ods-.* memory limit")
    rhoai_mem_footprint_core_usage: matbench_models.PrometheusValues = Field(..., alias="redhat-ods-.* memory usage")
    rhoai_cpu_footprint_core_request: matbench_models.PrometheusValues = Field(..., alias="redhat-ods-.* CPU request")
    rhoai_cpu_footprint_core_limit: matbench_models.PrometheusValues = Field(..., alias="redhat-ods-.* CPU limit")
    rhoai_cpu_footprint_core_usage: matbench_models.PrometheusValues = Field(..., alias="redhat-ods-.* CPU usage")

    rhoai_mem_footprint_model_request: matbench_models.PrometheusValues = Field(..., alias="watsonx-e2e.* memory request")
    rhoai_mem_footprint_model_limit: matbench_models.PrometheusValues = Field(..., alias="watsonx-e2e.* memory limit")
    rhoai_mem_footprint_model_usage: matbench_models.PrometheusValues = Field(..., alias="watsonx-e2e.* memory usage")
    rhoai_cpu_footprint_model_request: matbench_models.PrometheusValues = Field(..., alias="watsonx-e2e.* CPU request")
    rhoai_cpu_footprint_model_limit: matbench_models.PrometheusValues = Field(..., alias="watsonx-e2e.* CPU limit")
    rhoai_cpu_footprint_model_usage: matbench_models.PrometheusValues = Field(..., alias="watsonx-e2e.* CPU usage")

    rhoai_mem_footprint_knative_request: matbench_models.PrometheusValues = Field(..., alias="knative-.* memory request")
    rhoai_mem_footprint_knative_limit: matbench_models.PrometheusValues = Field(..., alias="knative-.* memory limit")
    rhoai_mem_footprint_knative_usage: matbench_models.PrometheusValues = Field(..., alias="knative-.* memory usage")
    rhoai_cpu_footprint_knative_request: matbench_models.PrometheusValues = Field(..., alias="knative-.* CPU request")
    rhoai_cpu_footprint_knative_limit: matbench_models.PrometheusValues = Field(..., alias="knative-.* CPU limit")
    rhoai_cpu_footprint_knative_usage: matbench_models.PrometheusValues = Field(..., alias="knative-.* CPU usage")

    rhoai_mem_footprint_servicemesh_request: matbench_models.PrometheusValues = Field(..., alias="istio-system memory request")
    rhoai_mem_footprint_servicemesh_limit: matbench_models.PrometheusValues = Field(..., alias="istio-system memory limit")
    rhoai_mem_footprint_servicemesh_usage: matbench_models.PrometheusValues = Field(..., alias="istio-system memory usage")
    rhoai_cpu_footprint_servicemesh_request: matbench_models.PrometheusValues = Field(..., alias="istio-system CPU request")
    rhoai_cpu_footprint_servicemesh_limit: matbench_models.PrometheusValues = Field(..., alias="istio-system CPU limit")
    rhoai_cpu_footprint_servicemesh_usage: matbench_models.PrometheusValues = Field(..., alias="istio-system CPU usage")

    rhoai_mem_footprint_other_operators_request: matbench_models.PrometheusValues = Field(..., alias="openshift-operators memory request")
    rhoai_mem_footprint_other_operators_limit: matbench_models.PrometheusValues = Field(..., alias="openshift-operators memory limit")
    rhoai_mem_footprint_other_operators_usage: matbench_models.PrometheusValues = Field(..., alias="openshift-operators memory usage")
    rhoai_cpu_footprint_other_operators_request: matbench_models.PrometheusValues = Field(..., alias="openshift-operators CPU request")
    rhoai_cpu_footprint_other_operators_limit: matbench_models.PrometheusValues = Field(..., alias="openshift-operators CPU limit")
    rhoai_cpu_footprint_other_operators_usage: matbench_models.PrometheusValues = Field(..., alias="openshift-operators CPU usage")

    # py_field_name: matbench_models.PrometheusValues = Field(..., alias="<metric description name>")


class Results(matbench_models.ExclusiveModel):
    metrics: Metrics


class Payload(matbench_models.ExclusiveModel):
    metadata: Metadata
    results: Results
