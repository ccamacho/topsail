import sys

from toolbox._common import RunAnsibleRole


ODS_CATALOG_IMAGE_DEFAULT = "quay.io/modh/qe-catalog-source"
ODS_CATALOG_IMAGE_VERSION_DEFAULT = "v160-8"
class RHODS:
    """
    Commands relating to RHODS
    """

    @staticmethod
    def deploy_ods(catalog_image=ODS_CATALOG_IMAGE_DEFAULT,
                   version=ODS_CATALOG_IMAGE_VERSION_DEFAULT):
        """
        Deploy ODS operator from its custom catalog

        Args:
          catalog_image: Optional. Container image containing ODS bundle.
          version: Optional. Version (catalog image tag) of ODS to deploy.
        """

        opts = {
            "rhods_deploy_ods_catalog_image": catalog_image,
            "rhods_deploy_ods_catalog_image_tag": version,
        }

        return RunAnsibleRole("rhods_deploy_ods", opts)

    @staticmethod
    def deploy_addon(cluster_name, wait_for_ready_state=True):
        """
        Installs the RHODS OCM addon

        Args:
            cluster_name: The name of the cluster where RHODS should be deployed.
            wait_for_ready_state: Optional. If true (default), will cause the role to wait until addon reports ready state. (Can time out)
        """

        opt = {
            "ocm_deploy_addon_id": "managed-odh",
            "ocm_deploy_addon_cluster_name": cluster_name,
            "ocm_deploy_addon_wait_for_ready_state": wait_for_ready_state,
        }

        return RunAnsibleRole("ocm_deploy_addon", opt)

    @staticmethod
    def test_jupyterlab(idp_name, username_prefix, user_count: int,
                        secret_properties_file, sut_cluster_kubeconfig="",
                        artifacts_collected="all"):
        """
        Test RHODS JupyterLab notebooks

        Args:
          idp_name: Name of the identity provider to use.
          user_count: Number of users to run in parallel
          secret_properties_file: Path of a file containing the properties of LDAP secrets. (See 'deploy_ldap' command)
          sut_cluster_kubeconfig: Optional. Path of the system-under-test cluster's Kubeconfig. If provided, the RHODS endpoints will be looked up in this cluster.
          artifacts_collected: Optional. 'all': collect all the artifacts generated by ODS-CI. 'no-image': exclude the images (.png) from the artifacts collected. 'none': do not collect any ODS-CI artifact. Default 'all'.:
        """

        opts = {
            "rhods_test_jupyterlab_idp_name": idp_name,
            "rhods_test_jupyterlab_username_prefix": username_prefix,
            "rhods_test_jupyterlab_user_count": user_count,
            "rhods_test_jupyterlab_secret_properties": secret_properties_file,
            "rhods_test_jupyterlab_sut_cluster_kubeconfig": sut_cluster_kubeconfig,
            "rhods_test_jupyterlab_artifacts_collected": artifacts_collected,
        }

        ARTIFACTS_COLLECTED_VALUES = ("all", "none", "no-image")
        if artifacts_collected not in ARTIFACTS_COLLECTED_VALUES:
            print(f"ERROR: invalid value '{artifacts_collected}' for 'artifacts_collected'. Must be one of {', '.join(ARTIFACTS_COLLECTED_VALUES)}")
            sys.exit(1)


        return RunAnsibleRole("rhods_test_jupyterlab", opts)

    @staticmethod
    def undeploy_ods(namespace="redhat-ods-operator", force: bool = False):
        """
        Undeploy ODS operator

        args:
          namespace: Optional. Namespace where ODS was installed.
          force: Optional. Force delete the RHODS namespaces.
        """

        opts = {
            "rhods_undeploy_ods_namespace": namespace,
            "rhods_undeploy_ods_force": force,
        }

        return RunAnsibleRole("rhods_undeploy_ods", opts)

    @staticmethod
    def cleanup_aws():
        """
        Cleanup AWS from RHODS dangling resources
        """

        return RunAnsibleRole("rhods_cleanup_aws")

    @staticmethod
    def deploy_ldap(idp_name, username_prefix, username_count: int, secret_properties_file, use_ocm=""):
        """
        Deploy OpenLDAP and LDAP Oauth

        Example of secret properties file:

        user_password=passwd
        admin_password=adminpasswd

        Args:
          idp_name: Name of the LDAP identity provider.
          username_prefix: Prefix for the creation of the users (suffix is 0..username_count)
          username_count: Number of users to create.
          secret_properties_file: Path of a file containing the properties of LDAP secrets.
          use_ocm: Optional. If set with a cluster name, use `ocm create idp` to deploy the LDAP identity provider.
        """

        opts = {
            "rhods_deploy_ldap_idp_name": idp_name,
            "rhods_deploy_ldap_username_prefix": username_prefix,
            "rhods_deploy_ldap_username_count": username_count,
            "rhods_deploy_ldap_secret_properties": secret_properties_file,
            "rhods_deploy_ldap_use_ocm": use_ocm,
        }

        return RunAnsibleRole("rhods_deploy_ldap", opts)

    @staticmethod
    def undeploy_ldap():
        """
        Undeploy OpenLDAP and LDAP Oauth
        """

        return RunAnsibleRole("rhods_undeploy_ldap")

    @staticmethod
    def reset_prometheus_db():
        """
        Resets RHODS Prometheus database, by destroying its Pod.
        """

        opts = {
            "cluster_prometheus_db_mode": "reset",
            "cluster_prometheus_db_label": "deployment=prometheus",
            "cluster_prometheus_db_namespace": "redhat-ods-monitoring",
        }

        return RunAnsibleRole("cluster_prometheus_db", opts)

    @staticmethod
    def dump_prometheus_db():
        """
        Dump Prometheus database into a file
        """

        opts = {
            "cluster_prometheus_db_mode": "dump",
            "cluster_prometheus_db_label": "deployment=prometheus",
            "cluster_prometheus_db_namespace": "redhat-ods-monitoring",
        }

        return RunAnsibleRole("cluster_prometheus_db", opts)

    @staticmethod
    def capture_state():
        """
        Capture information about the cluster and the RHODS deployment
        """

        return RunAnsibleRole("rhods_capture_state")
