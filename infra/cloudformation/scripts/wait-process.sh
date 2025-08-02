#!/bin/bash
stack_name=$1

while true; do
  STATUS=$(aws cloudformation describe-stacks \
    --stack-name "$stack_name" \
    --query "Stacks[0].StackStatus" \
    --output text 2>/dev/null)

  if [[ $? -ne 0 ]]; then
    echo "Stack $stack_name no longer exists (deleted)."
    break
  fi

  echo "Current status: $STATUS"

  case "$STATUS" in
    CREATE_COMPLETE|UPDATE_COMPLETE|DELETE_COMPLETE)
      echo "✅ Stack process finished successfully: $STATUS"
      break
      ;;
    *_IN_PROGRESS)
      echo "⏳ Stack is still in progress..."
      ;;
    *_FAILED|*ROLLBACK*)
      echo "❌ Stack failed with status: $STATUS"
      exit 1
      ;;
    *)
      echo "⚠️  Stack in unexpected status: $STATUS"
      ;;
  esac

  sleep 15
done
