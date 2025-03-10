set -euxo pipefail

retry() {
  local retries=$1
  shift
  local count=0

  set +x
  until "$@"; do
    exit_code=$?
    count=$((count + 1))
    if [ "$count" -lt "$retries" ]; then
      echo -n "."
      sleep 1  # Optional delay between retries
    else
      echo "Command failed after $count attempts."
      set -x
      return $exit_code
    fi
  done || true  # Prevent 'set -e' from exiting on failed command
  echo ""
  set -x
}

apply_model() {
  model_name=$1
  yq eval ".spec.cacheProfile = \"$CACHE_PROFILE\"" $REPO_DIR/manifests/models/$model_name.yaml | kubectl apply -f -
}