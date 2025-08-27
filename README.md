1. backup and restore docker images

```
$ docker images
REPOSITORY                            TAG       IMAGE ID       CREATED        SIZE
nvcr.io/nvidia/blueprint/vss-engine   2.3.1     4966655efabf   3 weeks ago    46.6GB
neo4j                                 5.26.4    e294727afca3   4 months ago   539MB


docker save -o neo4j.tar neo4j:5.26.4
docker save -o vss-engine.tar nvcr.io/nvidia/blueprint/vss-engine:2.3.1

aws s3 cp neo4j.tar s3://chenglimteo/neo4j.tar
aws s3 cp vss-engine.tar s3://chenglimteo/vss-engine.tar


```

2. Load the docker image on the other host

```

aws s3 cp s3://chenglimteo/neo4j.tar neo4j.tar
aws s3 cp s3://chenglimteo/vss-engine.tar vss-engine.tar
docker load -i neo4j.tar
docker load -i vss-engine.tar

$ docker images
REPOSITORY                            TAG       IMAGE ID       CREATED        SIZE
nvcr.io/nvidia/blueprint/vss-engine   2.3.1     4966655efabf   3 weeks ago    46.6GB
neo4j                                 5.26.4    e294727afca3   4 months ago   539MB

```

3. OOM

```
via-server-1  | [07/22/2025-05:45:38] [TRT-LLM] [E] Failed to initialize executor on rank 0: CUDA out of memory. Tried to allocate 136.00 MiB. GPU 0 has a total capacity of 14.56 GiB of which 58.38 MiB is free. Process 244271 has 26.06 MiB memory in use. Process 238746 has 1.08 GiB memory in use. Process 244515 has 468.00 MiB memory in use. Including non-PyTorch memory, this process has 12.90 GiB memory in use. Of the allocated memory 12.72 GiB is allocated by PyTorch, and 69.61 MiB is reserved by PyTorch but unallocated. If reserved but unallocated memory is large try setting PYTORCH_CUDA_ALLOC_CONF=expandable_segments:True to avoid fragmentation.  See documentation for Memory Management  (https://pytorch.org/docs/stable/notes/cuda.html#environment-variables)

```