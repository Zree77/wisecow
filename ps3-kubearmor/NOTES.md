# PS3 — KubeArmor Zero-Trust Policy: Environment Notes

## What was done
- Installed KubeArmor on the local Kind cluster (`karmor install`), all 4 core
  components (`controller`, `operator`, `relay`, and the runtime daemonset)
  came up healthy.
- Wrote and applied a zero-trust `KubeArmorPolicy` (`wisecow-kubearmor-policy.yaml`)
  scoped to the Wisecow pods, allowlisting only the expected processes
  (`fortune`, `cowsay`, `bash`, `wisecow.sh`) and restricting file access to
  `/etc/` and `/app/`.

## Known limitation on this environment
KubeArmor relies on a Linux Security Module (AppArmor or BPF-LSM) to observe
or enforce policy at the kernel level. Running `karmor probe` on this cluster
returns `Active LSM:` **blank**, and the KubeArmor daemonset is automatically
labeled by KubeArmor itself as:kubearmor.io/enforcer=none

This means the underlying kernel — WSL2's Linux kernel, used by Docker
Desktop/Kind on Windows — does not expose an LSM hook KubeArmor can attach
to. As a result, KubeArmor accepts and stores the policy correctly (visible
via `kubectl get kubearmorpolicy`), but cannot generate visibility or audit
events for it, since it has no OS-level mechanism to observe process/file
activity in the container.

This is a documented constraint of running KubeArmor inside Kind on
WSL2 — not a fault in the policy or its application. On a standard Linux
node (bare metal, cloud VM, or a Linux-native Docker host) with AppArmor or
BPF-LSM support, this same policy would produce visibility/audit logs (and,
depending on `action:`, enforcement) exactly as intended.

## Evidence
See `enforcer-none-evidence.png` — output of `kubectl get daemonset -n kubearmor`
showing the `kubearmor.io/enforcer=none` node selector label, confirming the
LSM constraint at the cluster level.
