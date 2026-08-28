#!/usr/bin/env bash
# RAM (GB), CPU %, CPU temp (k10temp), GPU % + temp (nvidia-smi) for polybar top bar.

ram_gb=$(awk '/MemTotal/{t=$2} /MemAvailable/{a=$2} END {printf "%.1f", (t-a)/1024/1024}' /proc/meminfo)

read -r u1 n1 s1 i1 io1 irq1 si1 st1 _ < <(awk '/^cpu /{print $2,$3,$4,$5,$6,$7,$8,$9,$10}' /proc/stat)
t1=$((u1 + n1 + s1 + i1 + io1 + irq1 + si1 + st1))
sleep 0.5
read -r u2 n2 s2 i2 io2 irq2 si2 st2 _ < <(awk '/^cpu /{print $2,$3,$4,$5,$6,$7,$8,$9,$10}' /proc/stat)
t2=$((u2 + n2 + s2 + i2 + io2 + irq2 + si2 + st2))
dt=$((t2 - t1))
di=$((i2 - i1))
cpu=0
if ((dt > 0)); then
  cpu=$(((dt - di) * 100 / dt))
fi

cputemp="?"
for hwmon in /sys/class/hwmon/hwmon*/name; do
  if [[ "$(cat "$hwmon" 2>/dev/null)" == "k10temp" ]]; then
    cputemp=$(awk '{printf "%d", $1/1000}' "$(dirname "$hwmon")/temp1_input" 2>/dev/null)
    break
  fi
done

gpu_data=$(nvidia-smi --query-gpu=utilization.gpu,temperature.gpu --format=csv,noheader,nounits 2>/dev/null | head -1)
gputil=$(echo "$gpu_data" | cut -d',' -f1 | tr -d ' ')
gputemp=$(echo "$gpu_data" | cut -d',' -f2 | tr -d ' ')

printf '󰍛 %sGB  󰘚 %s%% %s°C  󰢮 %s%% %s°C' \
  "$ram_gb" "$cpu" "$cputemp" "${gputil:-?}" "${gputemp:-?}"
