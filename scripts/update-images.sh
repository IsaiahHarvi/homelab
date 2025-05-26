NEW_TAG="0.0.23"

kubectl set image deployment/vd-api \
  api=ghcr.io/verus-datum/api:$NEW_TAG \
  -n default

kubectl set image deployment/vd-gui \
  gui=ghcr.io/verus-datum/gui:$NEW_TAG \
  -n default

kubectl set image deployment/vd-db \
  db=ghcr.io/verus-datum/db:$NEW_TAG \
  -n default

