#!/bin/bash

# File name for your .env file
ENV_FILE=".env"
# File name for the sealed secret
SEALED_SECRET_FILE="myapp-sealedsecret.yaml"

# Create the Secret manifest and pipe it to kubeseal
(
echo "apiVersion: v1"
echo "kind: Secret"
echo "metadata:"
echo "  name: myapp-secret"
echo "type: Opaque"
echo "data:"
# Read each line in the .env file and base64 encode the values
while IFS= read -r line
do
  # Split the line into key and value
  IFS='=' read -ra KV <<< "$line"
  KEY=${KV[0]}
  VALUE=${KV[1]}

  # Encode the value
  ENCODED_VALUE=$(echo -n $VALUE | base64)
  echo "  $KEY: $ENCODED_VALUE"
done < "$ENV_FILE"
) | kubeseal --format=yaml --controller-name=sealed-secrets --controller-namespace=kube-system > $SEALED_SECRET_FILE

echo "Sealed secret created in $SEALED_SECRET_FILE"