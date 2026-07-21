# Troubleshooting Kubernetes

For interview preparation it is important to look at how you would go about solving this problem, and talk through it rather than fixing it too. 

* Flag the severity to team members
* Start a war room
* Post-mortem (5W's)
* Future mitigation

When it comes to describing an incident, I reckon it will be on the lines of this:

**Gather Insights**
* Communicate with the team, assess the severity. Triage the issue. Don't guess blindly.
* Start a call with other engineers on call (if necessary). Most of the time it a faulty deployment / configuration
* Diagnose the system issue. 
  * Replicate for example if there is a 5XX error being thrown
* Inspect Observability. What do they show? (Console Metrics / Alarms, Prometheus, Grafana, Kibana)
* Inspect Deployment chain. Has there been a recent deployment? (ArgoCD, Helm, Git Updates)
* Before jumping in, isolate the stack.
* Verify the diagnosis with certain tools
  * Validate
  * Get nodes with `kubectl get nodes --all-namespaces` 
  * Get pods with `kubectl get pods --all-namespaces`
  * Get services with `kubectl get svc -n bluejay`

**Mitigation**
* Is the fix easy? Can we just deploy a new version of the docker image with the code fix?
* If it is a configuration issue, can we route traffic away quickly onto the newer version with a canary / rolling / blue-green deployment?
* 

What are the steps you would take to resolve XYZ ?
   * With GitOps, every change to y our infrastructure goes through a commit. ArgoCD acts as an enforcer to this.
   *
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
2. You have deployed some new configuration in Kubernetes, but now you want to rollback. What is the process for this, and how would it follow a GitOps procedure?
   * You inspect the `kubectl get (nodes/pods/deployment/svc)` & ArgoCD and attempt to diagnose the problem. 
   * If you had prometheus and/or grafana, you can visualise often how the deployment is going, and whether there are restarts.
   * You would go to the 
   * Get the 
   * If ArgoCD is enabled, you would lok at the most recent commit.
   * 
3. You deployed a new environment variables, but Kubernetes isn't fetching it from Google Secrets, how do you proceed
4. How would you roll-back a Canary deployment?

## Common Cases With Troubleshooting GKE Configuration



* We have `Jobs` and `Deployments` kinds in K8 Manifests. Jobs are just one-time things. When  we need to have deployments, which create Replica Sets and create continuously running applications.
  * What are some common issues you have with `Deployments`kinds?
* Then, how are services different?
  
## Common Cases with Troubleshooting ArgoCD


### Notes

* A readinessProbe might be very useful to know about. 
* Troubleshooting networking issues might include seeing if the container is running, then checking port mappings, checking firewalls
