# Cloud-Native-Monitoring-Stack
Automated Observability & Persistence for Enterprise-Grade Amazon EKS Clusters.

🎯 Purpose of the Project
The goal of this project is to move beyond simple infrastructure and demonstrate Full-Stack Observability. It transforms a "blind" Kubernetes cluster into a self-monitoring ecosystem that tracks health, performance, and resource costs in real-time using the industry-standard Prometheus and Grafana stack.

👥 Target Users & Stakeholder Value
1. The SRE / DevOps Engineer (The "Operator")
The Problem: Microservices are complex. When a pod crashes at 3:00 AM, finding the "needle in the haystack" log is nearly impossible.
The Solution: Integrated Prometheus Service Discovery. It automatically finds and scrapes every new pod for metrics (CPU, RAM, Network) without manual configuration.
Key Benefit: Mean Time to Recovery (MTTR). Engineers can identify the root cause of a failure in seconds via Grafana dashboards.
2. The Cloud Architect (The "Designer")
The Problem: EKS storage is ephemeral. If a monitoring pod restarts, all historical data (the "evidence") is deleted.
The Solution: Provisioned the AWS EBS CSI Driver via Terraform. This attaches persistent AWS Block Storage to the monitoring pods.
Key Benefit: Data Integrity. Monitoring history survives pod restarts and cluster updates.
3. The Financial Controller / CFO (The "Economist")
The Problem: Kubernetes can be a "black hole" for cloud costs.
The Solution: Deployed kube-state-metrics to visualize pod resource requests vs. actual usage.
Key Benefit: Cost Optimization. We can see exactly where we are over-provisioning and downsize instances to save money.
📊 Summary: Problem vs. Solution
User Role	Old "Blind" Problem	Your Automated Solution
SRE/DevOps	"Why is the API slow? I have no graphs."	Real-time Dashboards: Instant visibility into latency and errors.
Cloud Architect	"We lost all our monitoring data after a reboot."	Persistence: AWS EBS volumes store history permanently.
CFO/Owner	"Why is our AWS bill so high this month?"	Resource Tracking: Visualizing "Waste vs. Value" per namespace.
🛠 Tech Stack
Cloud: AWS (EKS, EBS, IAM, EC2, ELB)
IaC: Terraform (Modular EKS, AWS Add-ons)
Package Management: Helm v3 (Kube-Prometheus-Stack)
Observability: Prometheus, Grafana, Alertmanager
Storage: EBS CSI Driver (Persistent Volumes)
🚀 Step-by-Step Implementation
Phase 1: Infrastructure Stabilization
Stabilized the EKS Control Plane and Managed Node Groups using Terraform.
Resolved IAM "Conflict" errors by importing orphaned resources into the state file.
Phase 2: The Monitoring Engine (Helm)
Deployed the Kube-Prometheus-Stack via Helm into a dedicated monitoring namespace.
Configured Node Exporters to collect hardware-level metrics from EC2 workers.
Phase 3: Public Access & Persistence
Persistence: Automated the installation of the AWS EBS CSI Driver via Terraform Add-ons.
Access: Patched the Grafana service from ClusterIP to LoadBalancer, provisioning an AWS ELB for public dashboard access.
🔧 Engineering Challenges & Solutions (The "Hidden Bosses")
Challenge: The "Resource Tightrope" (t3.small Constraints)
The Problem: Running a full Prometheus stack on t3.small nodes (2GB RAM) pushed memory utilization to 62% before any apps were even deployed.
The Solution: Optimized the monitoring namespace by fine-tuning memory requests and temporarily scaling to 3 nodes to ensure the EBS CSI Driver had enough "headroom" to initialize without triggering OOM (Out of Memory) kills.
Challenge: Orphaned Resource Conflicts (409 Conflict)
The Problem: Manual cluster deletions left behind "Ghost" IAM roles and OIDC providers that blocked Terraform from re-provisioning.
The Solution: Utilized Terraform Import and state manipulation to "adopt" existing AWS resources back into the code, ensuring the main.tf remained the Single Source of Truth.
Challenge: Public Connectivity vs. Security
The Problem: Accessing the dashboard via port-forward was unstable and timed out frequently.
The Solution: Transitioned to a LoadBalancer service type. This offloaded the connection handling to an AWS Elastic Load Balancer (ELB), providing a stable public URL for stakeholders.
🏁 Final Project Status: COMPLETED
Infrastructure: Live & Persistent.
Visuals: Grafana Dashboards verified and screenshotted.
Cleanup: Automated terraform destroy confirmed to prevent cloud spend.
Next Project: [DevSecOps-Compliance-Guardrails] 🔜