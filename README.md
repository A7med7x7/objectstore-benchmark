# My Setup & Benchmarks 
 
### buckets 
I've created 2 different buckets on **CHI@UC** with the compute on **CHI@TACC** (GPU_NVIDIA bare metal)
- `s3_mount ` : later mounted via Ceph 
- `swift_mount`: via Swift 

-  installed rclone on the image 
		```dockerfile
		RUN curl -fsSL https://rclone.org/install.sh | bash 
		```
- mount the rclone config file from the *host* to the *container* (docker-compose.yml)
		 ```yml
		 ~/.config/rclone:/home/jovyan/.config/rclone
		  ```
```sh
#!/usr/bin/env bash

mkdir -p /home/jovyan/data/s3_mount
mkdir -p /home/jovyan/data/swift_mount
chown -R "${NB_UID:-1000}:${NB_GID:-100}" /home/jovyan/data || true

# fast flags
FAST_FLAGS=(
  --vfs-cache-mode full
  --vfs-fast-fingerprint
  --vfs-read-chunk-streams 10
  --no-modtime
  --transfers 10
)

# mounring
rclone mount rclone_s3:s3_mount /home/jovyan/data/s3_mount \
  "${FAST_FLAGS[@]}" \
  --daemon

rclone mount rclone_swift:swift_mount /home/jovyan/data/swift_mount \
  "${FAST_FLAGS[@]}" \
  --daemon
```


### Benchmarks 

- copying `Food-11.zip` (without performance flags)
```vb 
(base) jovyan@6a05b63cf540:~$ time cp data/Food-11.zip data/`s3_mount`/

real    0m11.230s
user    0m0.017s
sys     0m1.119s
(base) jovyan@6a05b63cf540:~$ time cp data/Food-11.zip data/`swift_mount`/

real    0m17.014s
user    0m0.017s
sys     0m1.114s
```
- copying `Food-11.zip` (with performance flags)

```vb 
(base) jovyan@6a05b63cf540:~$ time cp data/Food-11.zip data/`s3_mount`/

real 0m3.908s 
user 0m0.019s 
sys 0m1.072s 
(base) jovyan@6a05b63cf540:~$ time cp data/Food-11.zip data/`swift_mount`/

real 0m4.281s 
user 0m0.016s 
sys 0m1.131s 
```


- downloading from HuggingFace (set the HF_HOME to point the mounting point) (10-GB of data)(with performance flags)
		
```vb 
$s3

Loaded Yejy53/Echo-4o-Image in 260.61 seconds
Summary:
Original repo: 260.61 seconds

$swift 

Generating train split:
Loaded Yejy53/Echo-4o-Image in 260.61 seconds 
 Summary:
Original repo: 324.55 seconds


```

- copying `10-GB` of data(without performance flags)
```vb 
(base) jovyan@6a05b63cf540:~$ time cp -r  data/datasts/datasets/Yejy53___echo-4o-image/  data/`s3_mount`/hf_cache/dataset0

real    1m38.813s
user    0m0.181s
sys     0m9.750s

(base) jovyan@6a05b63cf540:~$ time cp -r  data/datasts/datasets/Yejy53___echo-4o-image/  data/`swift_mount`/hf_cache/dataset0

real    2m27.460s
user    0m0.168s
sys     0m8.709s
```
- copying `10-GB` of data(with performance flags)
```vb 
(base) jovyan@88aebd9a7821:~$ time cp -r  data/Yejy53___echo-4o-image/ data/`s3_mount`/hf_cache/datasets/dataset01 

real    0m34.139s
user    0m0.194s
sys     0m9.791s

(base) jovyan@88aebd9a7821:~$ time cp -r  data/Yejy53___echo-4o-image/ data/`swift_mount`/dataset01

real    0m46.162s
user    0m0.177s
sys     0m9.807s
```

- unzip `Food-11.zip` (without performance flags)
```vb
(base) jovyan@6a05b63cf540:~$ time unzip -q data/`s3_mount`/Food-11.zip

real    0m38.362s
user    0m15.712s
sys     0m3.799s

(base) jovyan@6a05b63cf540:~$ time unzip -q data/`swift_mount`/Food-11.zip

real    0m49.095s
user    0m16.625s
sys     0m5.224s
```
- unzip `Food-11.zip` (with performance flags)
```vb 
(base) jovyan@88aebd9a7821:~$ time unzip -q data/`s3_mount`/Food-11.zip 

real    0m14.664s

(base) jovyan@88aebd9a7821:~$ time unzip -q data/`swift_mount`/Food-11.zip 

real    0m17.228s

```