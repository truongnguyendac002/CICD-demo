# Order Service - CI/CD Practice (Ready to Step 3)

Project này đã được tạo sẵn đến hết bước **3) Chuẩn bị GCP (Artifact Registry + VM)**.

## 1) Local build/test/lint

Chạy tại thư mục `order-service`:

```powershell
mvn clean verify
mvn checkstyle:check
```

Nếu cần build Docker local:

```powershell
mvn clean package -DskipTests
docker build -t order-service:local .
docker run -d --name order-service-local -p 8080:8080 order-service:local
curl http://localhost:8080/actuator/health
docker rm -f order-service-local
```

## 2) Cấu trúc đã có

- Spring Boot app + endpoint `GET /api/ping`
- Actuator health endpoint
- Unit test mẫu
- Checkstyle lint config
- Dockerfile

## 3) Chuẩn bị GCP

### Option A - PowerShell (Windows)

```powershell
cd scripts/gcp
./prepare-gcp.ps1 -ProjectId "<gcp-project-id>" -Region "asia-southeast1" -Zone "asia-southeast1-a" -ArtifactRepo "order-service-repo"
```

### Option B - Bash

```bash
cd scripts/gcp
chmod +x prepare-gcp.sh vm-bootstrap.sh
./prepare-gcp.sh <gcp-project-id> asia-southeast1 asia-southeast1-a order-service-repo
```

Script sẽ:
- enable API cần thiết
- tạo Artifact Registry Docker repo
- tạo firewall rule mở TCP 8080
- tạo 2 VM: staging + production
- in ra external IP

## 4) Bootstrap Docker trên từng VM

SSH vào mỗi VM rồi chạy:

```bash
chmod +x vm-bootstrap.sh
./vm-bootstrap.sh
```

Sau đó logout/login lại để docker group có hiệu lực.

## 5) Thông tin image URI sau bước 3

```text
<region>-docker.pkg.dev/<project-id>/<artifact-repo>/order-service:<tag>
```

Ví dụ:

```text
asia-southeast1-docker.pkg.dev/my-project/order-service-repo/order-service:abc123
```
