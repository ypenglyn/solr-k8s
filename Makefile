PROJECT            = ${REPLACE_WITH_YOUR_GCP_ID}
ZONE               = ${REPLACE_WITH_YOUR_GCP_ZONE}
CLUSTER_NAME       = search
K8S_VER            = 1.9.2-gke.1
MACHINE_TYPE       = n1-standard-8
NUM_NODE           = 2
DISK_SIZE          = 100
RNAME              = l2r

.PHONY:
	help

help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

debug: ## dry run chart
	@helm install --dry-run --debug --name debug --namespace debug .

init:  ## create k8s cluster
	@gcloud beta container --project $(PROJECT) clusters create $(CLUSTER_NAME) \
        --zone $(ZONE) \
        --username "admin" \
        --cluster-version $(K8S_VER) \
        --machine-type $(MACHINE_TYPE) \
        --image-type "COS" \
        --disk-size $(DISK_SIZE) \
        --scopes "https://www.googleapis.com/auth/compute","https://www.googleapis.com/auth/devstorage.read_write","https://www.googleapis.com/auth/logging.write","https://www.googleapis.com/auth/monitoring","https://www.googleapis.com/auth/servicecontrol","https://www.googleapis.com/auth/service.management.readonly","https://www.googleapis.com/auth/trace.append" \
        --num-nodes $(NUM_NODE) \
        --network "default" \
        --enable-cloud-logging \
        --enable-cloud-monitoring \
        --subnetwork "default"

setup: ## setup helm
	@ while [[ $(shell gcloud beta container clusters --project $(PROJECT) --zone $(ZONE) describe $(CLUSTER_NAME) --format="value(status)") != "RUNNING" ]] ; do \
    echo "Waiting cluster be ready ..." ; \
    sleep 5 ; \
  done
	@gcloud container clusters get-credentials $(CLUSTER_NAME) --zone $(ZONE) --project $(PROJECT)
	@kubectl create clusterrolebinding add-on-cluster-admin --clusterrole=cluster-admin --serviceaccount=kube-system:default
	@helm init

list:   ## list released charts
	@helm list
 
release: ## release chart
	@helm install --name $(RNAME) --namespace default .

upgrade: ## update chart release
	@helm upgrade $(RNAME) .

delete: ## delete released chart
	@helm delete $(RNAME)
