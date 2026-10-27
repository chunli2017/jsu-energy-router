@echo off
rem ============================================================
rem 江苏大学省力步行规划智能体 - 一键启动脚本
rem 用法：双击运行，或在命令行执行 run.bat
rem ============================================================
chcp 65001 >nul
setlocal
cd /d "%~dp0"

echo.
echo === 江苏大学爬坡校园省力步行规划智能体 ===
echo.

rem ---- 1. 依赖检测与安装（清华镜像） ----
python -c "import fastapi, uvicorn, networkx, requests, openpyxl, httpx" >nul 2>&1
if errorlevel 1 (
    echo [依赖] 缺少依赖，正在通过清华镜像安装...
    python -m pip install -r requirements.txt -i https://pypi.tuna.tsinghua.edu.cn/simple
    if errorlevel 1 (
        echo [错误] 依赖安装失败，请检查网络或手动执行：
        echo        python -m pip install -r requirements.txt -i https://pypi.tuna.tsinghua.edu.cn/simple
        pause
        exit /b 1
    )
) else (
    echo [依赖] 已就绪
)

rem ---- 2. 数据构建（若无 graph.json） ----
if not exist "data\graph.json" (
    echo [数据] 未找到 graph.json，开始构建数据管线（外网失败自动降级内置样例）...
    python scripts\build_data.py
    if errorlevel 1 (
        echo [错误] 数据构建失败
        pause
        exit /b 1
    )
) else (
    echo [数据] 已存在 graph.json，跳过构建
)

rem ---- 3. 启动服务 ----
echo.
echo [启动] http://127.0.0.1:8000  （Ctrl+C 停止）
echo.
python -m uvicorn api.main:app --host 127.0.0.1 --port 8000

endlocal
