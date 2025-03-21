#!/bin/bash
set -e

echo "Waiting for workflow '$WORKFLOW_NAME' to complete..."

# Calculate timeout in seconds
TIMEOUT=$((TIMEOUT_MINUTES * 60))
START_TIME=$(date +%s)
END_TIME=$((START_TIME + TIMEOUT))

while true; do
  CURRENT_TIME=$(date +%s)
  
  # Check if timeout has been reached
  if [ $CURRENT_TIME -gt $END_TIME ]; then
    echo "Timeout reached after $TIMEOUT_MINUTES minutes. Workflow '$WORKFLOW_NAME' did not complete in time."
    exit 1
  fi
  
  # Get workflow runs for the current SHA
  WORKFLOW_RUNS=$(curl -s -H "Authorization: token $GITHUB_TOKEN" \
    -H "Accept: application/vnd.github.v3+json" \
    "https://api.github.com/repos/$GITHUB_REPOSITORY/actions/runs?head_sha=$GITHUB_SHA")
  
  # Extract the status of the target workflow
  TARGET_WORKFLOW=$(echo "$WORKFLOW_RUNS" | jq -r --arg name "$WORKFLOW_NAME" '.workflow_runs[] | select(.name == $name)')
  
  if [ -z "$TARGET_WORKFLOW" ]; then
    echo "Workflow '$WORKFLOW_NAME' not found for SHA: $GITHUB_SHA. Waiting..."
  else
    STATUS=$(echo "$TARGET_WORKFLOW" | jq -r '.status')
    CONCLUSION=$(echo "$TARGET_WORKFLOW" | jq -r '.conclusion')
    RUN_ID=$(echo "$TARGET_WORKFLOW" | jq -r '.id')
    
    echo "Workflow status: $STATUS, conclusion: $CONCLUSION"
    
    # Check if workflow has completed
    if [ "$STATUS" == "completed" ]; then
      if [ "$CONCLUSION" == "success" ]; then
        echo "Workflow '$WORKFLOW_NAME' completed successfully!"
        exit 0
      else
        echo "Workflow '$WORKFLOW_NAME' failed with conclusion: $CONCLUSION"
        echo "See details: https://github.com/$GITHUB_REPOSITORY/actions/runs/$RUN_ID"
        exit 1
      fi
    fi
  fi
  
  echo "Waiting $POLL_INTERVAL seconds before checking again..."
  sleep $POLL_INTERVAL
done 