# 使用

## Windows

- 下载 Python 3.10.x
- 如果需要使用 CUDA 加速则需要安装 CUDA 11.2 和 cuDDN 8.1
- 运行 `pip install -r requirements.txt` 下载包
- 运行 `train.bat` 就可以运行了

## macOS

- 系统自带的 `python3` 版本太旧时，请到 https://www.python.org/downloads/macos/ 装 Python 3.10+，或 `brew install python@3.11`
- 安装依赖（`requirements.txt` 是 Windows/CUDA 专用的，mac 请用 `requirements-mac.txt`）：

  ```bash
  python3 -m pip install -r requirements-mac.txt
  ```

  Apple Silicon（M 系列）想启用 GPU(Metal) 加速的话，改用：

  ```bash
  python3 -m pip install tensorflow-macos tensorflow-metal
  ```

- 启动方式（三选一）：

  ```bash
  chmod +x run_mac.sh run_mac.command   # 首次需要赋权
  ./run_mac.sh                          # ① 终端启动
  ./run_mac.sh --check                  # ② 只做环境自检，不开界面
  ```

  ③ 在 Finder 里双击 `run_mac.command`（启动过程会写入 `launch_mac.log`）

- macOS 专属适配：
  - 双击启动时自动把工作目录切回项目根目录，并让窗口前置到最前
  - Retina 屏自动调整 Tk 缩放；Dark Mode 下自动切换日志配色
  - 中文 / emoji 字体按本机真实字体族探测（PingFang SC / Hiragino / Arial Unicode）
  - 训练曲线图的中文字体自动补全（原本写死的 PingFang.ttc 在较新 macOS 上不存在）
  - 快捷键：`⌘R` 开始 · `⌘E` 导出 · `⌘T` 训练页 · `⌘U` 测试页 · `⌘W` 关窗
  - 训练 / 测试进行中关窗会二次确认，避免误触 `⌘W` 掐掉长时间训练

---

# 界面

主界面分成两个页签：

- **训练**：数据源 → 训练参数 → 训练/取消/导出 → 实时日志 → 训练A/B/C/D 结果页；
  训练完成后可把导出目录自动回填到「测试」页。
- **测试**：模型配置 → 数据配置 → 开始测试 → 区域A–G 结果页；
  支持 图像分类 / 图像回归 / 单图批量识别 三种任务。

## 查看不全的内容怎么办

参数区和结果区之间有一条**可拖动的分隔条**，上下比例可以自由调整。此外：

| 位置 | 滚动方式 |
| --- | --- |
| 上方参数区（区域①②③） | 鼠标滚轮 / 右侧滚动条；内容比窗口宽时按 **Shift+滚轮** 或拖**底部横向滚动条** |
| 训练日志 | 自带横竖滚动条，滚轮滚日志本身（不会误滚参数区） |
| 结果文本框（区域A–G） | 自带横竖滚动条，**Shift+滚轮** 可横向滚 |
| 结果图表 | 直接拖拽 / 缩放（matplotlib 工具栏），「全部图表总览」页可滚动 |
| 「训练说明」「欢迎」页 | 整页可滚动 |

> 滚动条是**按需自动显隐**的：内容装得下时不占地方；一旦装不下就会自动出现。
> 所有长段提示文字都已设置自动换行，不会横向溢出屏幕。

---

# 数据准备

- 将 `橙子` 数据集加入 `./resources/datasets/橙子` 中
- 将 `非橙子` 数据集加入 `./resources/datasets/非橙子` 中

---

# 代码解释

trainer_ops是带优化器的库
trainer是只有常规ADAM优化器的库

---

# 目录说明

| 路径 | 说明 |
| --- | --- |
| `main.py` | 图形界面主程序（训练 + 测试） |
| `base/trainer.py` | 训练库（冻结 MobileNetV2 特征 + 自训练分类头） |
| `base/predictor.py` | 识别库 |
| `base/sdd.py` | 模型 zip 解压工具 |
| `model/basemodels/model.json` | 冻结的 MobileNetV2(alpha=0.5) 特征提取图 |
| `model/models_keras/` | 训练导出目录（metadata.json / model.json / weights.bin / 训练曲线） |
| `resources/datasets/` | 训练数据（橙子 / 非橙子） |
| `resources/testsets/` | 测试图片 |
| `resources/runtime/` | 便携 Python 运行时（仅 Windows） |
| `run_mac.sh` / `run_mac.command` | macOS 启动脚本 |
| `requirements-mac.txt` | macOS 依赖清单 |
