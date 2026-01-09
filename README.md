# Hub & Spoke Network Topology (Terraform)

## 📖 Project Overview

This project provisions a scalable **Hub & Spoke** network architecture using AWS Transit Gateway.
Instead of using complex VPC Peering meshes (which scale poorly), this design uses a central "Router" (Transit Gateway) to manage traffic between isolated environments.

## 🏗 Architecture

The infrastructure consists of 3 distinct VPCs and a central gateway:

1. **Hub VPC (10.0.0.0/16):** The "Shared Services" network. Intended for central tools (VPN, Security Scanners, Jenkins).
2. **Dev VPC (10.1.0.0/16):** The development sandbox.
3. **Prod VPC (10.2.0.0/16):** The production environment.
4. **AWS Transit Gateway:** The central hub that connects all VPCs.

## ⚙️ Technical Depth

* **Transit Gateway Attachments:** Each VPC is attached to the TGW via a specific subnet.
* **Route Tables:** Custom routing logic is implemented to direct traffic.
* *Logic:* "If traffic is destined for `10.x.x.x`, send it to the Transit Gateway."


* **Remote State:** Uses the S3 Backend from Project 1 to maintain state consistency.

## 💻 Usage

```bash
# Initialize (pulls remote state config)
terraform init

# Deploy Network
terraform apply

```

## 🧠 Key Concepts Learned

* **CIDR Planning:** Allocating non-overlapping IP ranges (`10.0`, `10.1`, `10.2`) to ensure routability.
* **Centralized Routing:** Managing network traffic flows via TGW Route Tables rather than individual peering connections.
* **State Separation:** Isolating the Network Layer (Project 2) from the Management Layer (Project 1).

---

### **What is Next: Project 3**

Now that the roads (Network) are built, we need to put some cars (Servers) on them.
