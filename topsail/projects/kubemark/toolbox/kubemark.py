import os
import sys

from topsail._common import RunAnsibleRole, AnsibleRole, AnsibleMappedParams, AnsibleConstant, AnsibleSkipConfigGeneration


class Kubemark:
    """
    Commands relating to kubemark deployment
    """

    @AnsibleRole("cluster_deploy_kubemark_capi_provider")
    @AnsibleMappedParams
    def deploy_kubemark_capi_provider(self):
        """
        Deploy the Kubemark Cluster-API provider

        Args:
        """

        return RunAnsibleRole(locals())


    @AnsibleRole("cluster_deploy_kubemark_nodes")
    @AnsibleMappedParams
    def deploy_kubemark_nodes(self,
                              namespace="openshift-cluster-api",
                              deployment_name="kubemark-md",
                              count=4):
        """
        Deploy a set of Kubemark nodes

        Args:
          namespace: the namespace in which the MachineDeployment will be created
          deployment_name: the name of the MachineDeployment
          count: the number of nodes to deploy
        """

        return RunAnsibleRole(locals())
