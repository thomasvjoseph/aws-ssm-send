#!/bin/sh
set -e

if [ -z "$INPUT_INSTANCE_ID" ] || [ -z "$INPUT_COMMANDS" ] || [ -z "$INPUT_REGION" ]; then
  echo "Error: instance-id, region, and commands inputs are required."
  exit 1
fi

echo "🛰️ Running remote SSM command on instance $INPUT_INSTANCE_ID..."

# Convert multiline command string to a JSON array
COMMANDS_JSON=$(echo "$INPUT_COMMANDS" | jq -R -s -c 'split("\n") | map(select(length > 0))')

echo "📜 Parsed Commands: $COMMANDS_JSON"

# Send command via SSM
COMMAND_ID=$(aws ssm send-command \
  --document-name "AWS-RunShellScript" \
  --targets "Key=instanceids,Values=$INPUT_INSTANCE_ID" \
  --parameters "{\"commands\":$COMMANDS_JSON}" \
  --region "$INPUT_REGION" \
  --query "Command.CommandId" \
  --output text)

echo "✅ Command sent (ID: $COMMAND_ID). Waiting for execution..."

aws ssm wait command-executed \
  --region "$INPUT_REGION" \
  --command-id "$COMMAND_ID" \
  --targets "Key=instanceids,Values=$INPUT_INSTANCE_ID"

echo "📦 Command output:"
aws ssm get-command-invocation \
  --command-id "$COMMAND_ID" \
  --instance-id "$INPUT_INSTANCE_ID" \
  --region "$INPUT_REGION"