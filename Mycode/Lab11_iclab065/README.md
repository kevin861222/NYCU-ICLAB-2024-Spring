### Lab11 實驗概述
1. Low power design。
2. 設計一個 Siamese Neural Network ，並使用 data_gating 與 clock_gating 降低功耗。
   > SNN 包含：
   Convolution
   Quantization
   Max Poolong
   Fully connected
   Another Quantization
   Encoding
   L1 Distance

3. 使用 JasperGold 驗證加入 CG 後電路功能。
4. 加入 CG 需達成降低 25% 總耗電量。

### 實驗評論
1. 使用 Primetime 進行功耗模擬，練習省電設計
2. 這個題目設計的不是很好，測資是一般矩陣，並不是稀疏矩陣，加入 CG 效果不彰。
3. 一個設計良好的電路很難達到 25% 的門檻，除非加入冗余電路。

### Tips

1. Quantization 用 Case 爆開不會比較省面積。
2. gate_or ip 名稱不要亂取，要按照助教規定格式。
3. gate_en 判斷條件盡可能簡潔，減少組合電路造成額外功耗。
4. 這道題目使用 data_gating 就能達到很好的 PPA ，功耗表現也很卓越，但題目要求要使用 GATED_IP ，反而增加更多組和電路，靜態功耗上升，再加上題目並未特別設計測資，我的初始設計供好和面積都優於加入 GATED_IP 的版本。
   > Data_gating :
   cal_input 是運算的輸入，在運算的閒置狀態固定輸入就能減少邏輯切換只要對源頭做控制，就能讓整個運算流程的功耗大幅降低。
   ```Verilog
   always @(*) begin
    if (statement) begin 
        cal_input = input_data ;
    end else begin
        cal_input = 0 ;
    end
   end
   ```
   

