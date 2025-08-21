# UC-NODE

Welcome! This project is designed to help you **run ML experiments on Chameleon Cloud** with minimal setup, follow the guide below in order to know how to use the generated project. 

## Purpose of this README

This README is for **users who have already generated the project**.  
It explains how to **provision resources, creating confuguring servers using notebooks, and setup your environment** on Chameleon Cloud.  

> If you are looking for instructions on **how to generate this project** from the template, see the **[main README](https://github.com/A7med7x7/ReproGen/blob/dev/README.md) at the root of the template repository**.

### Prerequisites

- You must have a [Chameleon Cloud](https://chameleoncloud.org) account, and an allocation as part of a project. 
- You should have already configured SSH keys at the Chameleon site that you plan to use, e.g. following [Hello, Chameleon](https://teaching-on-testbeds.github.io/hello-chameleon/).


## Provisioning resources on Chameleon Cloud

The `chi` directory in your newly created project automates setting up data buckets, bringing up compute instances, and launching a fully configured Jupyter environment with MLFlow experiment tracking for your machine learning experiments.

In [Chameleon JupyterHub](https://jupyter.chameleoncloud.org/hub/), clone your new project and open the `chi` directory.

```sh 
git clone https://github.com/A7med7x7/objectstore-benchmark.git
```

### First run only: Create object store buckets

At the beginning of your project, you will create buckets in Chameleon's object store, to hold datasets, metrics, and artifacts from experiment runs. Unlike data saved to the ephemeral local disk of the compute instance, this data will persist beyond the lifetime of the compute instance.

Inside the `chi` directory, run the notebook [`0_create_buckets.ipynb`](chi/0_create_buckets.ipynb) to create these buckets.

### Launching a compute instance

When you need to work on your project, you will launch a compute instance on Chameleon Cloud.

First, you will [reserve an instance](https://chameleoncloud.readthedocs.io/en/latest/technical/reservations/gui_reservations.html). Use your project name as a prefix for your lease name.
(e.g UC-NODE)_gpu_p100
Then, to provision your server and configure it for your project, you will run:






- [`chi/1_create_server_amd.ipynb`](chi/1_create_server_amd.ipynb)






---

### Configure and start your Jupyter environment

On your computer instance (SSH-ing from your local machine via shell), generate the `.env` file required for Docker Compose:
From your **home directory** (`~`), run:

```sh
bash ./UC-NODE/scripts/generate_env.sh
```

you will be prompted to enter your HuggingFace Token,after inputting.
you should see something like:

`✅ The .env file has been generated successfully at : /home/cc/.env`

---

From your **home directory** (`~`), run:

```sh
docker compose --env-file ~/.env -f UC-NODE/docker/docker-compose.yml up -d --build
```



for amd 
```sh
docker compose --env-file ~/.env -f UC-NODE/docker/docker-compose-amd.yml up -d --build
```

---

### Login to Jupyter Lab and MLFlow UI

after your build finished, with the output 

```sh
[+] Running 5/5
 ✔ docker-jupyter          Built                                                                                                             
 ✔ docker-mlflow           Built                                                                                                             
 ✔ Network docker_default  Created                                                                                                           
 ✔ Container mlflow        Started                                                                                                     
 ✔ Container jupyter       Started        
 ```

you can access your Jupyter Lab and MLflow UI 
1. Access your jupyter: you can grab the token from running image using the command:

```sh
docker exec jupyter jupyter server list | tail -n 1 | cut -f1 -d" " | sed "s/localhost/$(curl -s ifconfig.me)/"
```

Open the printed URL in your browser.
2. Access MLflow UI 

```sh
echo "http://$(curl -s ifconfig.me):$(docker port mlflow 8000 | cut -d':' -f2)"

```
Open this URL in your browser to see your experiments and logs.

### 5.5. Stop the Containerized Environment

If you’d like to pause your environment, you can stop the running containers with the command:

```sh
docker compose --env-file ~/.env -f UC-NODE/docker/docker-compose.yml down
```



for amd 
```sh
docker compose --env-file ~/.env -f UC-NODE/docker/docker-compose-amd.yml down
```


This will stop and remove the containers, but all your data in mounted volumes will remain safe.
When you want to restart later, simply run the docker compose up command again (see Step 4).

### pushing code to GitHub 
once you have completed your first experiment run, you can push your code to GitHub. We've pre-installed the GitHub CLI in your container to make this easy.
First, sync your account by running this command
```sh
gh auth login --hostname github.com --git-protocol https --web <<< $'Y\n'
```
follow the instruction and you are ready to git push

---

### 6. Clean Up Resources

When finished, delete your server to free up resources.

**In Chameleon JupyterHub, open and run:**

- [`chi/3_delete_resources.ipynb`](chi/3_delete_resources.ipynb)