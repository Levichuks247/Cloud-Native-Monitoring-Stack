# Cloud-Native-Monitoring-Stack

> **Automated Observability & Persistence for Enterprise-Grade Amazon EKS Clusters.**

## 🎯 Purpose of the Project
The goal of this project is to move beyond simple infrastructure and demonstrate **Full-Stack Observability**. It transforms a "blind" Kubernetes cluster into a self-monitoring ecosystem that tracks health, performance, and resource costs in real-time using the industry-standard Prometheus and Grafana stack.

---

## 👥 Target Users & Stakeholder Value

### 1. The SRE / DevOps Engineer (The "Operator")
* **The Problem:** Microservices are complex. Finding a "needle in the haystack" log during a crash is nearly impossible.
* **The Solution:** Integrated **Prometheus Service Discovery**. It automatically finds and scrapes every new pod for metrics.
* **Key Benefit:** **Mean Time to Recovery (MTTR)**. Engineers identify root causes in seconds via Grafana.

### 2. The Cloud Architect (The "Designer")
* **The Problem:** EKS storage is ephemeral. If a monitoring pod restarts, all historical data is deleted.
* **The Solution:** Provisioned the **AWS EBS CSI Driver** via Terraform. This attaches persistent block storage to the pods.
* **Key Benefit:** **Data Integrity**. Monitoring history survives pod restarts and cluster updates.

### 3. The Financial Controller / CFO (The "Economist")
* **The Problem:** Kubernetes can be a "black hole" for cloud costs.
* **The Solution:** Deployed `kube-state-metrics` to visualize pod resource requests vs. actual usage.
* **Key Benefit:** **Cost Optimization**. Visualizing "Waste vs. Value" to downsize instances and save money.

---

## 📊 Summary: Problem vs. Solution

| User Role | Old "Blind" Problem | Your Automated Solution |
| :--- | :--- | :--- |
| **SRE/DevOps** | "Why is the API slow? I have no graphs." | **Real-time Dashboards:** Instant visibility into latency. |
| **Cloud Architect** | "We lost all our monitoring data after a reboot." | **Persistence:** AWS EBS volumes store history permanently. |
| **CFO/Owner** | "Why is our AWS bill so high this month?" | **Resource Tracking:** Visualizing usage per namespace. |

---

## 🛠 Tech Stack
* **Cloud:** AWS (EKS, EBS, IAM, EC2, ELB)
* **IaC:** Terraform (Modular EKS, AWS Add-ons)
* **Package Management:** Helm v3 (`kube-prometheus-stack`)
* **Observability:** Prometheus, Grafana, Alertmanager
* **Storage:** EBS CSI Driver (Persistent Volumes)

---

## 🚀 Step-by-Step Implementation

### Phase 1: Infrastructure Stabilization
* Stabilized the EKS Control Plane and Managed Node Groups using **Terraform**.
* Resolved IAM "Conflict" errors by importing orphaned resources into the state file.

### Phase 2: The Monitoring Engine (Helm)
* Deployed the **Kube-Prometheus-Stack** via Helm into a dedicated `monitoring` namespace.
* Configured Node Exporters to collect hardware-level metrics from EC2 workers.

### Phase 3: Public Access & Persistence
* **Persistence:** Automated the installation of the **AWS EBS CSI Driver** via Terraform Add-ons.
* **Access:** Patched the Grafana service from `ClusterIP` to `LoadBalancer`, provisioning an AWS ELB for public access.

---

## 🔧 Engineering Challenges & Solutions

### Challenge: The "Resource Tightrope" (t3.small Constraints)
* **The Problem:** Running a full Prometheus stack on `t3.small` nodes pushed memory utilization to **62%**.
* **The Solution:** Optimized the namespace by fine-tuning memory requests and temporarily scaling to 3 nodes to ensure the **EBS CSI Driver** had enough headroom to initialize.

### Challenge: Orphaned Resource Conflicts (409 Conflict)
* **The Problem:** Manual cluster deletions left behind "Ghost" IAM roles that blocked Terraform.
* **The Solution:** Utilized **Terraform Import** and state manipulation to "adopt" existing AWS resources back into the code.

### Challenge: Public Connectivity vs. Security
* **The Problem:** Accessing the dashboard via `port-forward` was unstable and timed out frequently.
* **The Solution:** Transitioned to a **LoadBalancer** service type, offloading connection handling to an AWS Elastic Load Balancer (ELB).

---

## 🏁 Final Project Status: COMPLETED
* **Infrastructure:** Live & Persistent.
* **Visuals:** Grafana Dashboards verified and screenshotted.
* **Cleanup:** Automated `terraform destroy` confirmed to prevent cloud spend.

**Next Project:** `[DevSecOps-Compliance-Guardrails]` 🔜