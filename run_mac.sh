#!/bin/bash
# =====================================================================
# macOS 启动脚本（终端用）—— 与 Windows 的 train.bat / predictor.bat 对位
#
#   chmod +x run_mac.sh        # 首次执行需要赋权
#   ./run_mac.sh               # 启动「训练 + 测试」一体化 GUI
#   ./run_mac.sh --check       # 只做环境自检，不打开窗口
#   ./run_mac.sh train.py      # 跑指定脚本（兼容旧的命令行用法）
# =====================================================================
set -uo pipefail

# 始终在脚本所在目录运行，避免从别处调用时相对路径失效
cd "$(dirname "$0")" || exit 1
PROJECT_ROOT="$(pwd)"

echo "=========================================================="
echo " 橙子识别项目 —— macOS 启动器"
echo " 项目目录: $PROJECT_ROOT"
echo "=========================================================="

# ---------- 1. 找 Python 3.10+ ----------
# 优先级：项目自带 runtime（若是 mac 版）> python3.10 > python3
pick_python() {
    # 项目内自带的 mac 版解释器（如果放了 resources/runtime/bin/python3）
    if [ -x "$PROJECT_ROOT/resources/runtime/bin/python3" ]; then
        echo "$PROJECT_ROOT/resources/runtime/bin/python3"
        return
    fi
    for cand in python3.12 python3.11 python3.10 python3; do
        if command -v "$cand" >/dev/null 2>&1; then
            # 校验版本 >= 3.10
            ver=$("$cand" -c 'import sys;print("%d%d"%sys.version_info[:2])' 2>/dev/null)
            if [ -n "$ver" ] && [ "$ver" -ge 310 ]; then
                command -v "$cand"
                return
            fi
        fi
    done
}

PY="$(pick_python)"
if [ -z "$PY" ]; then
    echo ""
    echo "[错误] 没有找到 Python 3.10 或更高版本。"
    echo "       请任选一种方式安装："
    echo "         1) 官方安装包：https://www.python.org/downloads/macos/"
    echo "         2) Homebrew  ：brew install python@3.11"
    echo ""
    read -n 1 -s -r -p "按任意键关闭…"
    exit 1
fi

echo "[系统] 使用解释器: $PY"
"$PY" -c 'import sys;print("[系统] Python 版本:", sys.version.split()[0])'

# ---------- 2. 依赖自检 ----------
MISSING=""
for m in numpy PIL tensorflow sklearn matplotlib; do
    if ! "$PY" -c "import $m" >/dev/null 2>&1; then
        MISSING="$MISSING $m"
    fi
done

if [ -n "$MISSING" ]; then
    echo ""
    echo "[警告] 缺少依赖:$MISSING"
    echo ""
    echo "  macOS 安装命令（Apple Silicon 推荐 tensorflow-macos + tensorflow-metal）："
    echo "    $PY -m pip install -r requirements-mac.txt"
    echo ""
    echo "  若只想快速跑起来（Intel Mac / 不需要 GPU 加速）："
    echo "    $PY -m pip install numpy pillow tensorflow scikit-learn matplotlib"
    echo ""
    read -n 1 -s -r -p "是否仍然继续尝试启动？(y/N) " ans
    if [ "$ans" != "y" ] && [ "$ans" != "Y" ]; then
        exit 1
    fi
else
    echo "[系统] 依赖检查通过 ✔"
fi

# ---------- 3. 显卡/加速器提示 ----------
"$PY" - <<'PYEOF' 2>/dev/null
try:
    import tensorflow as tf
    gpus = tf.config.list_physical_devices("GPU")
    if gpus:
        print("[系统] 已检测到加速设备:", ", ".join(g.name for g in gpus))
    else:
        print("[系统] 未检测到 GPU/Metal 设备，将使用 CPU（训练仍可正常运行）")
except Exception as e:
    print("[警告] TensorFlow 探测失败:", e)
PYEOF

# ---------- 4. 启动 ----------
if [ "${1:-}" = "--check" ]; then
    echo "[系统] 自检完成，未启动界面。"
    exit 0
fi

TARGET="${1:-main.py}"
shift 2>/dev/null || true

echo "[系统] 启动: $TARGET"
echo "----------------------------------------------------------"
# 用 exec 让 Python 直接接管，Ctrl+C 信号能直达程序
exec "$PY" "$TARGET" "$@"
