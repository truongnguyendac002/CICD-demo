param(
  [Parameter(Mandatory = $true)][string]$ProjectId,
  [string]$Region = "asia-southeast1",
  [string]$Zone = "asia-southeast1-a",
  [string]$ArtifactRepo = "order-service-repo",
  [string]$StagingVmName = "order-stg-vm",
  [string]$ProdVmName = "order-prod-vm",
  [string]$MachineType = "e2-medium",
  [string]$ImageFamily = "ubuntu-2204-lts",
  [string]$ImageProject = "ubuntu-os-cloud"
)

$ErrorActionPreference = "Stop"

Write-Host "Setting active project..."
gcloud config set project $ProjectId

Write-Host "Enabling required APIs..."
gcloud services enable artifactregistry.googleapis.com compute.googleapis.com

Write-Host "Creating Artifact Registry (if missing)..."
$repoExists = gcloud artifacts repositories list --location=$Region --format="value(name)" | Select-String -Pattern "/$ArtifactRepo$"
if (-not $repoExists) {
  gcloud artifacts repositories create $ArtifactRepo --repository-format=docker --location=$Region --description="Order service Docker repository"
} else {
  Write-Host "Artifact Registry '$ArtifactRepo' already exists."
}

Write-Host "Creating firewall rule for port 8080 (if missing)..."
$fwExists = gcloud compute firewall-rules list --filter="name=allow-order-service-8080" --format="value(name)"
if (-not $fwExists) {
  gcloud compute firewall-rules create allow-order-service-8080 --allow=tcp:8080 --target-tags=order-service --description="Allow inbound 8080 for order-service"
} else {
  Write-Host "Firewall rule 'allow-order-service-8080' already exists."
}

Write-Host "Creating staging VM (if missing)..."
$stgExists = gcloud compute instances list --filter="name=($StagingVmName)" --zones=$Zone --format="value(name)"
if (-not $stgExists) {
  gcloud compute instances create $StagingVmName --zone=$Zone --machine-type=$MachineType --image-family=$ImageFamily --image-project=$ImageProject --tags=order-service
} else {
  Write-Host "VM '$StagingVmName' already exists."
}

Write-Host "Creating production VM (if missing)..."
$prodExists = gcloud compute instances list --filter="name=($ProdVmName)" --zones=$Zone --format="value(name)"
if (-not $prodExists) {
  gcloud compute instances create $ProdVmName --zone=$Zone --machine-type=$MachineType --image-family=$ImageFamily --image-project=$ImageProject --tags=order-service
} else {
  Write-Host "VM '$ProdVmName' already exists."
}

Write-Host "Collecting VM external IPs..."
$stagingIp = gcloud compute instances describe $StagingVmName --zone=$Zone --format="value(networkInterfaces[0].accessConfigs[0].natIP)"
$prodIp = gcloud compute instances describe $ProdVmName --zone=$Zone --format="value(networkInterfaces[0].accessConfigs[0].natIP)"

Write-Host ""
Write-Host "=== RESULT ==="
Write-Host "Artifact Registry: $Region-docker.pkg.dev/$ProjectId/$ArtifactRepo"
Write-Host "Staging VM IP: $stagingIp"
Write-Host "Production VM IP: $prodIp"
Write-Host ""
Write-Host "Next step: bootstrap each VM with scripts/gcp/vm-bootstrap.sh"
