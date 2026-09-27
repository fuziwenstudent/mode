#!/bin/bash
# =====================================================================
# macOS 双击启动器（Finder 里双击本文件即可）
#
# 首次使用：
#   chmod +x run_mac.command        # 终端执行一次即可
# 之后：
#   在 Finder 里直接双击 run_mac.command
#
# 说明：Finder 双击时的工作目录是 "/"，所以这里先 cd 到脚本所在目录，
#       并把 run_mac.sh 的所有输出同时写进启动日志，方便排查问题。
# =====================================================================
cd "$(dirname "$0")" || exit 1

LOG="launch_mac.log"
{
    echo ""
    echo "===== $(date '+%Y-%m-%d %H:%M:%S') 启动 ====="
} >> "$LOG"

# 用 Terminal 窗口显示启动过程，结束时保留窗口让用户看到结果
if [ -x "./run_mac.sh" ]; then
    ./run_mac.sh "$@" 2>&1 | tee -a "$LOG"
    status=${PIPESTATUS[0]}
else
    echo "[错误] 找不到 run_mac.sh，请先确认文件完整。"
    echo "[错误] 找不到 run_mac.sh" >> "$LOG"
    status=1
fi

if [ "$status" -ne 0 ]; then
    echo ""
    echo "=========================================================="
    echo " 启动失败（退出码 $status）"
    echo " 详细日志：$LOG"
    echo "=========================================================="
    read -n 1 -s -r -p "按任意键关闭…"
fi
exit "$status"
