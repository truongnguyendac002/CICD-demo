#!/usr/bin/env bash
set -euo pipefail

PROJECT_ID="${1:-}"
REGION="${2:-asia-southeast1}"
ZONE="${3:-asia-southeast1-a}"
ARTIFACT_REPO="${4:-order-service-repo}"
STAGING_VM_NAME="${5:-order-stg-vm}"
PROD_VM_NAME="${6:-order-prod-vm}"
MACHINE_TYPE="${7:-e2-medium}"
IMAGE_FAMILY="${8:-ubuntu-2204-lts}"
IMAGE_PROJECT="${9:-ubuntu-os-cloud}"

if [[ -z "$PROJECT_ID" ]]; then
  echo "Usage: ./prepare-gcp.sh <PROJECT_ID> [REGION] [ZONE] [ARTIFACT_REPO] [STAGING_VM_NAME] [PROD_VM_NAME]"
  exit 1
fi

gcloud config set project "$PROJECT_ID"
gcloud services enable artifactregistry.googleapis.com compute.googleapis.com

if ! gcloud artifacts repositories describe "$ARTIFACT_REPO" --location="$REGION" >/dev/null 2>&1; then
  gcloud artifacts repositories create "$ARTIFACT_REPO" --repository-format=docker --location="$REGION" --description="Order service Docker repository"
else
  echo "Artifact Registry '$ARTIFACT_REPO' already exists."
fi

if ! gcloud compute firewall-rules describe allow-order-service-8080 >/dev/null 2>&1; then
  gcloud compute firewall-rules create allow-order-service-8080 --allow=tcp:8080 --target-tags=order-service --description="Allow inbound 8080 for order-service"
else
  echo "Firewall rule 'allow-order-service-8080' already exists."
fi

if ! gcloud compute instances describe "$STAGING_VM_NAME" --zone="$ZONE" >/dev/null 2>&1; then
  gcloud compute instances create "$STAGING_VM_NAME" --zone="$ZONE" --machine-type="$MACHINE_TYPE" --image-family="$IMAGE_FAMILY" --image-project="$IMAGE_PROJECT" --tags=order-service
else
  echo "VM '$STAGING_VM_NAME' already exists."
fi

if ! gcloud compute instances describe "$PROD_VM_NAME" --zone="$ZONE" >/dev/null 2>&1; then
  gcloud compute instances create "$PROD_VM_NAME" --zone="$ZONE" --machine-type="$MACHINE_TYPE" --image-family="$IMAGE_FAMILY" --image-project="$IMAGE_PROJECT" --tags=order-service
else
  echo "VM '$PROD_VM_NAME' already exists."
fi

STAGING_IP=$(gcloud compute instances describe "$STAGING_VM_NAME" --zone="$ZONE" --format="value(networkInterfaces[0].accessConfigs[0].natIP)")
PROD_IP=$(gcloud compute instances describe "$PROD_VM_NAME" --zone="$ZONE" --format="value(networkInterfaces[0].accessConfigs[0].natIP)")

echo "=== RESULT ==="
echo "Artifact Registry: $REGION-docker.pkg.dev/$PROJECT_ID/$ARTIFACT_REPO"
echo "Staging VM IP: $STAGING_IP"
echo "Production VM IP: $PROD_IP"
