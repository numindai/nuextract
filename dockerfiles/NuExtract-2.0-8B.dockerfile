#!/usr/bin/env -S docker build . --secret id=hf_token,src=${HOME}/.cache/huggingface/token --build-arg CPU=1 -t numind_nuextract-2_0-8b.cpu --file

# If CPU is defined, we will use the CPU image, else the GPU one
ARG CPU
ARG BASE_IMAGE=${CPU:+cpu_image}
ARG BASE_IMAGE=${BASE_IMAGE:-gpu_image}
FROM public.ecr.aws/q9t5s3a7/vllm-cpu-release-repo:0.10.2 AS cpu_image
FROM vllm/vllm-openai:0.10.2 AS gpu_image
FROM ${BASE_IMAGE}

# We need to redefine CPU after the FROM line
ARG CPU

#### Model Download ####
# Very long so it is better to not modify this section & before often
ARG HF_TOKEN
ENV HF_HUB_ENABLE_HF_TRANSFER=1
RUN pip install --no-cache-dir huggingface_hub[hf_transfer]

# Download each safetensors in a RUN command
RUN --mount=type=secret,id=hf_token \
    HF_TOKEN=${HF_TOKEN:-$(cat /run/secrets/hf_token)} \
    hf download numind/NuExtract-2.0-8B \
        model-00001-of-00004.safetensors && \
    rm -fr /root/.cache/huggingface/xet
RUN --mount=type=secret,id=hf_token \
    HF_TOKEN=${HF_TOKEN:-$(cat /run/secrets/hf_token)} \
    hf download numind/NuExtract-2.0-8B \
        model-00002-of-00004.safetensors && \
    rm -fr /root/.cache/huggingface/xet
RUN --mount=type=secret,id=hf_token \
    HF_TOKEN=${HF_TOKEN:-$(cat /run/secrets/hf_token)} \
    hf download numind/NuExtract-2.0-8B \
        model-00003-of-00004.safetensors && \
    rm -fr /root/.cache/huggingface/xet
RUN --mount=type=secret,id=hf_token \
    HF_TOKEN=${HF_TOKEN:-$(cat /run/secrets/hf_token)} \
    hf download numind/NuExtract-2.0-8B \
        model-00004-of-00004.safetensors && \
    rm -fr /root/.cache/huggingface/xet

# Download the rest of files
RUN --mount=type=secret,id=hf_token \
    HF_TOKEN="${HF_TOKEN:-$(cat /run/secrets/hf_token)}" \
    hf download numind/NuExtract-2.0-8B && \
    rm -fr /root/.cache/huggingface/xet
#### End of Model Download ####

# Fix for cpu image which defines its workspace in a different location
RUN if [ ! -d /vllm-workspace ]; then ln -s /workspace /vllm-workspace; fi
WORKDIR /vllm-workspace

ARG RCONFIG=
ARG BUCKET=compiled-models
ARG CACHE=/vllm-workspace/cache
ARG VLLM_CACHE=/root/.cache/vllm/torch_compile_cache

RUN apt-get update && \
    apt-get install -y --no-install-recommends rclone zstd jq && \
    apt-get clean && rm -rf /var/lib/apt/lists/* && \
    vllm --version 2>/dev/null | tail -n1 > /tmp/vllm_version && \
    mkdir -p "$CACHE" && \
    mkdir -p "${VLLM_CACHE}" && \
    mkdir -p /root/.config/rclone

RUN --mount=type=secret,id=rclone_config \
    cat <<EOT > set_rclone.sh && chmod +x set_rclone.sh && ./set_rclone.sh
#!/usr/bin/env bash
RCONFIG="\${RCONFIG:-\$(cat /run/secrets/rclone_config 2>/dev/null)}"
if [ -n "\${RCONFIG}" ] && \
    rclone config dump --quiet | jq -e '. | length == 0' >/dev/null; then
    echo "Setting rclone configuration"
    echo "\${RCONFIG}" > /root/.config/rclone/rclone.conf
fi
# rclone config can be set by docker mount
if rclone config dump --quiet | jq -e '. | length > 0' >/dev/null; then
    echo -n "\$(rclone listremotes | head -n1)${BUCKET}/" > /tmp/remote
    echo "$(cat /tmp/vllm_version)/numind_nuextract-2_0-8b" >> /tmp/remote
    touch /tmp/rclone_push_args
    if rclone config dump --quiet | jq -e '.[] | .type == "s3"' >/dev/null; then
        echo "--s3-no-check-bucket" > /tmp/rclone_push_args
    fi
fi
EOT

RUN cat <<EOT > download.sh && chmod +x download.sh && ./download.sh
#!/usr/bin/env bash
if rclone config dump --quiet | jq -e '. | length == 0' >/dev/null; then
    echo "No rclone configuration, disabling cache download" >&2
    exit 0
fi
echo "Starting cache download"
rclone copy -v --retries 1 "\$(cat /tmp/remote)" "$CACHE" \
    2> >(grep -v 'directory not found' >&2)
find "$CACHE" -maxdepth 1 -type f -name '*.tar.zst' \\
    -exec tar -I zstdmt -xf {} -C "${VLLM_CACHE}" \;
echo "Cache download finished"
EOT

RUN cat <<EOT > upload.sh && chmod +x upload.sh
#!/usr/bin/env bash
if rclone config dump --quiet | jq -e '. | length == 0' >/dev/null; then
    echo "No rclone configuration, disabling cache syncronization" >&2
    exit 0
fi
while ! curl http://127.0.0.1:8000/health >/dev/null 2>&1; do sleep 1; done
echo "Starting cache upload"
find "${VLLM_CACHE}" -mindepth 1 -maxdepth 1 -type d | \\
    while IFS= read -r model_dir; do
        hash="\$(basename \${model_dir})"
        archive="$CACHE/\${hash}.tar.zst"
        if [[ ! -f "\${archive}" ]]; then
            echo "[INFO] Compressing: \${model_dir} -> \${archive}"
            tar -I zstdmt -cf "\${archive}" -C "${VLLM_CACHE}" "\${hash}"
            rclone copy -vv \$(cat /tmp/rclone_push_args) \\
                "\${archive}" "\$(cat /tmp/remote)"
        else
            echo "[SKIP] Archive already exists: \${archive}"
        fi
    done
echo "Cache upload finished"
EOT

RUN cat <<EOT > run.sh && chmod +x run.sh
#!/usr/bin/env bash
./set_rclone.sh
./download.sh
./upload.sh &
SYNC_PID=$!
cleanup() {
    echo "Cleaning up..."
    kill -9 $SYNC_PID 2>/dev/null
}
trap cleanup EXIT INT TERM

python3 -m vllm.entrypoints.openai.api_server \\
    --model numind/NuExtract-2.0-8B \\
    --chat-template-content-format openai \\
    --generation-config vllm \\
    --tensor-parallel-size ${CPU:-"\$(nvidia-smi --list-gpus | wc -l)"} \\
    ${CPU:+"--max-model-len 8192"} \$@
EOT

ENV VLLM_ENGINE_ITERATION_TIMEOUT_S=300
ENV HF_HUB_OFFLINE=1

ENTRYPOINT [ "./run.sh" ]
