# Troubleshooting Kubernetes

For interview preparation it is important to look at how you would go about solving this problem, and talk through it rather than fixing it too. 

* Flag the severity to team members
* Start a war room
* Post-mortem (5W's)
* Future mitigation

When it comes to describing an incident, I reckon it will be on the lines of this:

1. What are the first things you would do?
2. How would you debug XZY?
3. What are the steps you would take to resolve XYZ ?
   * GitOps Rollback via ArgoCD
   
4. What else do you need to keep in mind?
5. How might you mitigate this in the future?

### Configuration Resolution

Imagine in a production incident you have a `CrashLoopBackOff`. After investigation and resolution the best way to roll out correct configuration again is:

* If ArgoCD is in use, then you would correct the configuration and redeploy
  * You do this with ... 
* Otherwise, with `kubectl patch` ? Can you find out more information on this?

## Common Cases With Troubleshooting Running Pods

1. `CrashLoopBackOff` (Exit Code 137 vs. EC 1)
   * `Exit Code 137 (OOKilled)`: Resource / breached memory limits.
   * `Exit Code 1 (General Failure):` Other ContainerRunTimeErrors, App Crashes
   * Continuously restarting, based on how many retries. 
   * You will also see `Error` at first on inspection. Resolves to CLBF eventually.
   * Debug with `kubectl get pods -n <namespace>` and then `kubectl logs <name> -n <namespace>`. 
   * You will find the same on the Google Console / Workloads / in the / logs 

## Common Cases With Deploying Apps in Kubernetes

1. Pod Stuck in `Pending`
   * This could be when the Scheduler, a part of the `ControlPlane`
   * Causes: Cannot find a node that satisfies the constraints; Insufficient CPU/Memory for the pod; missing persistent volumes
2. 

## Common Cases With Troubleshooting GKE Configuration



* We have `Jobs` and `Deployments` kinds in K8 Manifests. Jobs are just one-time things. When  we need to have deployments, which create Replica Sets and create continuously running applications.
  * What are some common issues you have with `Deployments`kinds?
* Then, how are services different?
  
## Common Cases with Troubleshooting ArgoCD


### Notes

* A readinessProbe might be very useful to know about. 
* Troubleshooting networking issues might include seeing if the container is running, then checking port mappings, checking firewalls
