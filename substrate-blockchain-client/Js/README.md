# JS scripts for substrate

Note: All scripts are in TypeScript due to to many type confusion when using JavaScript

## Send use case accident

```bash
clear; ts-node xcm_test_use_case.ts
```

## Get block stats

```bash
clear; ts-node get_block_stats.ts
#Or:
while :; do ts-node get_block_stats.ts; sleep 5; done
```

## Listen to events

```bash
clear; ts-node listen_events.ts
```