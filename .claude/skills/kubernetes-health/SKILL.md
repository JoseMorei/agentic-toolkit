---
name: kubernetes-health
description: Read-only health check for applications on Kubernetes. Finds crashing, stuck, or out-of-memory pods and explains why in plain language. Use when someone asks whether an app or namespace is healthy, or mentions CrashLoopBackOff, OOMKilled, Pending, or ImagePullBackOff.
argument-hint: <namespace> [app name]
---

# Kubernetes health check

Find out whether the applications in a namespace are running properly, and if not, **why**. Use only read-only
`kubectl` commands (`get`, `describe`, `logs`, `top`, `events`). Never delete, restart, scale, or edit anything.

## Steps

1. **Confirm where you are.** Run `kubectl config current-context` and state which cluster you are looking at.
   If it doesn't match the incident, stop and ask.

2. **Overview.**
   - `kubectl get pods -n <namespace> -o wide`: look for pods that are not `Running`/`Ready`, have many restarts, or
     are very new or very old compared with their siblings.
   - `kubectl get deploy,statefulset,daemonset -n <namespace>`: are the desired and ready counts equal?

3. **Recent events.** `kubectl events -n <namespace>` (or `kubectl get events -n <namespace> --sort-by=.lastTimestamp`).
   Warnings here usually point straight at the cause.

4. **Dig into unhealthy pods.** For each one, run `kubectl describe pod` and read the logs (use `--previous` if the
   container restarted). Match what you see to a common pattern:

   | What you see | What it usually means |
   |---|---|
   | `CrashLoopBackOff` | The app starts and then crashes. The logs (`--previous`) usually say why. |
   | `OOMKilled` | The app used more memory than allowed. Compare usage (`kubectl top pod`) with its limit. |
   | `Pending` | No node can take the pod: not enough CPU/memory, or rules that rule out every node. Read the events. |
   | `ImagePullBackOff` / `ErrImagePull` | The image name or tag is wrong, or the cluster can't log in to the registry. |
   | Running but not `Ready` | The app is up but failing its health check. Check the probe settings and the logs. |
   | Many restarts, now fine | It was failing earlier. Note when and why, since it may come back. |

5. **Check the nodes, if many pods are affected.** `kubectl get nodes` and `kubectl describe node <name>`: look for
   `NotReady`, memory or disk pressure, or a node that recently joined or left.

## Output

```
Cluster / namespace: <context> / <namespace>
Overall: healthy | degraded | down
Problems found:
- <pod or workload>: <pattern> — <evidence> — <likely cause>
Suggested next step (for a human): <one safe action>
```

Do not read Kubernetes Secrets, and don't paste secret values into the chat even if you come across them.
