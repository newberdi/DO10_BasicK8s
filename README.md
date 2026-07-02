## D09 - Kubernetes Basics

**Project status:** Completed.

Fundamentals of container orchestration using Kubernetes. The project covers deploying a microservice application using custom-written manifests, working with ConfigMap and Secrets, and applying update strategies.

### Table of Contents

- [About the Project](#about-the-project)
- [Key Skills](#key-skills)
- [Completed Tasks](#completed-tasks)
- [Project Structure](#project-structure)

### About the Project

This project is dedicated to learning Kubernetes as a container orchestration platform. In the first stage, a ready-made application from the provided manifest was deployed. In the second stage, custom manifests for a microservice application were written from scratch: ConfigMap and Secrets were configured, and Pods and Services for PostgreSQL, RabbitMQ, and seven microservices were described. Testing was performed via Postman, and application update strategies (Recreate and Rolling Update) were studied with redeployment time measurement.

All work was performed in a Minikube environment.

### Key Skills

The following technologies and tools were learned and applied during the project:

- **Kubernetes:** writing manifests (YAML), working with Pods, Services, ConfigMap, Secrets
- **Minikube:** deploying a local cluster, creating tunnels, working with the dashboard
- **kubectl:** applying manifests, viewing and diagnosing objects, reading logs, decoding Secrets
- **Postman:** functional API testing of a microservice application
- **Deployment Strategies:** Recreate, Rolling Update, measuring redeployment time

### Completed Tasks

The project consists of two parts:

1.  **Ready-Made Manifest:**
    - Launching a Kubernetes environment with 4 GB of memory.
    - Applying the ready-made manifest from `/src/example`.
    - Launching the Kubernetes dashboard and creating tunnels to access services.
    - Verifying the application's functionality via a browser.
2.  **Custom Manifest:**
    - Creating a ConfigMap with database and service hosts.
    - Creating Secrets with passwords, logins, and authorization keys.
    - Describing Pods and Services for PostgreSQL, RabbitMQ, and seven microservices.
    - Sequentially applying manifests and checking object status.
    - Decoding Secrets and checking container logs.
    - Creating tunnels and running functional tests via Postman.
    - Examining cluster state through the Kubernetes dashboard.
    - Updating the application using Recreate and Rolling Update strategies, measuring redeployment time.

### Project Structure

- `src/example/` — ready-made manifest for Part 1
- `src/app/` — manifests for the microservice application (ConfigMap, Secrets, Pods, Services)

> A complete step-by-step report with all screenshots and listings is located in the `REPORT.md` file.