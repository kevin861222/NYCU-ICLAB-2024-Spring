### Lab05實驗概述
1. 使用 SRAM 存取資料，進行 8x8 , 16x16 , 32x32 的 Convolution , Max Pooling , Deconvolution 運算
2. SRAM 是 Hard IP ，需考慮響應延遲。

### 實驗評論

受限於面積上限以及 SRAM 的存取讀取缺乏彈性，算法很花時間，電路規模也非常龐大，很容易出錯，是這門課數一數二困難的實驗。

### Tips

1. 這是這門課到目前為止規模最大的電路，建議先參照網路資源再開始想算法。
   > bestcode : https://github.com/hankshyu/ICLab-2023/tree/main/src/Lab05/Exercise
   > 這是別人的 repo ，密碼不要問我
   > 裡面只有投影片沒有 code ，請不要抄襲
2. Conv 和 Deconv 可以共用硬體資源，Deconv 只要對 kernel 做旋轉就會變成 conv 。
3. 先確保算法在任何 size 下都能正確運作，再開始寫 code。
4. SRAM Dout 建議擋一道 reg。
5. 一個資料是8bit，受限於 SRAM 資料寬度，一定會遇上斷層問題，可以開第二顆 SRAM 或是額外的 reg 來解決此問題
   > 斷層問題:
   > 假設 SRAM 一個地址的資料寬度是40bits，也就是五筆資料，輸入 addr=0 會得到第一筆到第五筆資料。這樣的讀取方式會造成無法在一次訪問取得第二筆到第六筆資料，造成運算停滯。

### 其他叮囑
1. Lab5 往年都是 Lab12 的素材，Lab12 就是用 Lab5 的電路進行 APR ，鮮少人有時間重新改 Lab5 的電路，因此 Lab5 的排名會直接影響 Lab12 的排名。
2. 電路設計不良會造成 APR 問題，尤其 SRAM 的部分最為顯著，建議 input output 都擋 reg。
   > reg 後接一些小型組合電路再接到 SRAM 是可以允許的。
3. APR 的問題成因很複雜，一言難盡，有些人沒有擋 reg 也沒事，但有些人擋了還是 06 unknown。

### 備注
做電路最講求的就是謹慎，只要一個小地方出錯就是全錯，最忌諱貪快。
如果 01sim 有驗出 bug 都好解決，最怕01有過03出錯，細節可以看「03_Violation解法」中的說明。