#!/usr/bin/env bash
#
# Daily recursive ZFS snapshot for entire Gandalf pool
# Keeps 7 most recent top-level snapshots, rotates older ones

#—————— Config ——————
PATH=/usr/bin:/usr/sbin:/bin:/sbin
POOL="Gandalf"
LOGFILE="/mnt/grimoire/tmp/zfs-daily-snap.log"
PREFIX="daily"
MAX_SNAPS=7
#———————————————————————

DATESTAMP=$(/bin/date +%Y-%m-%d)
SNAPNAME="${PREFIX}-${DATESTAMP}"
FULL="${POOL}@${SNAPNAME}"

# Start logging
exec >> "$LOGFILE" 2>&1

echo "[$(/bin/date '+%F %T')] Creating recursive snapshot: $FULL"
/sbin/zfs snapshot -r "$FULL"

echo "[$(/bin/date '+%F %T')] Snapshot created. Now pruning old snapshots..."

# Get list of top-level snapshots matching pattern, excluding today's
TOP_SNAPS=$(/sbin/zfs list -t snapshot -o name -s creation \
  | /bin/grep "^${POOL}@${PREFIX}-" \
  | /bin/grep -v "${FULL}")

# Count how many old snapshots exist
TOTAL_SNAPS=$(echo "$TOP_SNAPS" | wc -l)

# If more than MAX_SNAPS - 1 exist, prune oldest
if [ "$TOTAL_SNAPS" -ge "$MAX_SNAPS" ]; then
  PRUNE_COUNT=$((TOTAL_SNAPS - MAX_SNAPS + 1))
  SNAPSHOTS_TO_PRUNE=$(echo "$TOP_SNAPS" | head -n "$PRUNE_COUNT")

  for snap in $SNAPSHOTS_TO_PRUNE; do
    echo "[$(/bin/date '+%F %T')] Destroying recursive snapshot: $snap"
    /sbin/zfs destroy -r "$snap"
  done
else
  echo "[$(/bin/date '+%F %T')] No old snapshots to prune."
fi

echo "[$(/bin/date '+%F %T')] Daily snapshot complete."
