# 4.0.3
## Modification of files
The referenced Docker images were changed.

## Change MongoDB and Redis-Persistent reclaim policy
The MongoDB and Redis-Persistent reclaim policies for PersistentVolumes have been changed from `Delete` to `Retain`. Using `Retain` as the reclaim policy is much safer as deleting the PV will not automatically delete the data when the product runs in e.g. a cloud environment.

---

# 4.0.2
## Modification of files
The referenced Docker images were changed.

---

# 4.0.1
## Modification of files
The referenced Docker images were changed.

---

## 4.0.0
This is the public release of Cognigy.AI version 4.0.0! We have completely re-structured this repository. Please consult our updated `Installation and Dev-Ops guide` in order to stand how you can work with this updated repository.
