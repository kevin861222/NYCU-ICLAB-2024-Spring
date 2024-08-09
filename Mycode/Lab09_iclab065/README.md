### Lab09 實驗概述
1. System Verilog 練手 Pattern / Checker Project
2. 驗證 RTL 正確性以及有效產生 Pattern 。
3. 驗證 Pattern 覆蓋率。

### 實驗評論
1. System Verilog 提供多個實用的驗證功能，其中 Assertion 可以用更高階的方法約束電路行為，Coverage 可以檢視驗證隨機性是否滿足驗證計畫，在這個實驗中能深刻體會 SV 所帶來的優勢。

### Tips

1. 把語法看熟一點，善用網路資源。
2. Coverpoint / group 寫法非常多元，小心不要寫出永遠打不到的 cover。
3. 務必先理解 iff ( if and only if ) 使用時機。
4. 覆蓋率會被 DRAM 資料影響。
5. 可以先計算最小測資數量再開始動工。

### 其他叮囑
1. 可以拿自己 Lab9 的 Pattern 回頭驗證 Lab8 的 RTL 看看有沒有疏漏。