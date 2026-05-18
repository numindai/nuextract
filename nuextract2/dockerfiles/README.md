Optimized Dockerfile for NuExtract
==================================

- Each image can be built targeting x86 CPU (need an AVX512 capable CPU)
or GPU (Cuda). However, GPTQ models are not supported by vLLM CPU at the
moment.
- They include the advertised model with optimized layers to accelerate
transfers.
- Automatic tensor-parallel-size based on the number of NVIDIA GPUs.
- Option to add a rclone configuration to synchronize vLLM compilation cache
to reduce starting time
- Tested with vLLM 0.10.2

### Build an image for CPU with advanced shebang

```
./NuExtract-2.0-8B.dockerfile
```

### Build the image directly with docker build command

For CPU
```
docker build . \
    --build-arg CPU=1 \
    -t NuExtract-2.0-8B.cpu \
    -f NuExtract-2.0-8B.dockerfile
```

For GPU
```
docker build . \
    -t NuExtract-2-8B \
    -f NuExtract-2-8B.dockerfile
```

### Test the image

Run
```
docker run -it --rm --name nuextract --network=host \
    NuExtract-2.0-8B.cpu
```

Run for GPU
```
docker run -it --rm --name nuextract --network=host \
    --runtime nvidia --gpus all \
    NuExtract-2.0-8B
```

### Extra vLLM arguments

Any following arguments in the docker command will be passed to vLLM.

For example, if you want to add an api-key (strongly recommanded):
```
docker run -it --rm --name nuextract --network=host \
    --runtime nvidia --gpus all \
    NuExtract-2.0-8B --api-key putarealsecret
```

Then:
```
curl http://localhost:8000/v1/models -H "Authorization: Bearer putarealsecret"
```

### RClone configuration

Create a rclone.conf file with a S3 bucket (for instance) configured (see
[https://rclone.org/commands/rclone_config/]()). If well configured, you should
be able to list the files (if you named your bucket "compiled-models"):
```
rclone ls s3:/compiled-models
```

Then mount it when running the docker. Example (for CPU):
```
docker run -it --rm --name nuextract --network=host \
    --mount type=bind,source=rclone.conf,target=/root/.config/rclone/rclone.conf,readonly=true \
    NuExtract-2.0-8B.cpu
```

#### Health check

```
curl http://localhost:8000/health
```

#### Test NuExtract in your cli (need jq)

```
curl -s http://localhost:8000/v1/models | \
  jq -r '.data[0].id' | \
  xargs -I MODEL_NAME \
  curl -s -X POST http://localhost:8000/v1/chat/completions \
    -H 'Content-Type: application/json' \
    -d '{
    "messages":[{
      "content":[{
        "text":"Liam is here contrary to Alex who is in Taïwan.
                Samuel will come tomorrow with Charles",
        "type":"text"
      }],
      "role":"user"
    }],
    "model":"MODEL_NAME",
    "chat_template_kwargs":{
      "template":"{\\"names\\": [\\"verbatim_string\\"],\\"countries\\": [\\"verbatim_string\\"]}",
    "examples":[{
      "input":"Sam is CTO",
      "output":"{\\"names\\": [\\"Sam\\"]}"}
    ]}
    }' | \
  jq -r '.choices[0].message.content'
```

Copyable version
```
curl -s http://localhost:8000/v1/models | jq -r '.data[0].id' | xargs -I MODEL_NAME curl -s -X POST http://localhost:8000/v1/chat/completions -H 'Content-Type: application/json' -d '{ "messages":[{"content":[{"text":"Liam is here contrary to Alex who is in Taïwan. Samuel will come tomorrow with Charles","type":"text"}],"role":"user"}],"model":"MODEL_NAME","chat_template_kwargs":{"template":"{\\"names\\": [\\"verbatim_string\\"],\\"countries\\": [\\"verbatim_string\\"]}","examples":[{"input":"Sam est le boss","output":"{\\"names\\": [\\"Sam\\"]}"}]}}' | jq -r '.choices[0].message.content'
```
