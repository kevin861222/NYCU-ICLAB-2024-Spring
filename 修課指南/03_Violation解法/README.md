終於找到工作了，閒暇之餘更新一下，此文件僅根據自身修課經驗統整，如消息有誤，請告知我更正。\
email: kevin861222@gmail.com

### 模擬流程說明
1. 01 (VCS_RTL_SIM)
   > 編譯、檢查語法錯誤、功能性驗證
2. 02 (DC_shell)
   > 合成、產生 sdf (Standard Delay Format)
3. 03 (VCS_GATE_SIM)
   > 加入延遲後的功能性驗證

### 03 error 成因
1. 01 模擬遇上瑕疵，功能性本來就有錯誤，但是未被發現
2. coding style 不良，造成 02 合成出錯誤電路
3. 忘記改 pattern.v 中的 CYCLE_TIME

### 03 error 痛點
02 合成會將電路優化，其中包含各式各樣的化簡、合併，會將非 DFF 的訊號重新命名，造成 03sim 的波形只剩下一部分 DFF 訊號可以觀察。

這些 DFF 訊號還會包含一些 Z (高阻抗) ，是因為優化器發現特定位元的 DFF 可以和其他 DFF 共用，因此將他們化簡，才導致波形變成 Z ，這種只有特定 bit 被化簡的訊號不會顯示在 02 log 中，並且變成 Z 不影響電路功能性，只是造成 debug 通靈成分增加。

### 03 error 錯誤類型、對應解法

遇上 03 一律建議先檢查路徑是否正確、 pattern.v 中的 CYCLE_TIME 使否更正。

#### 1. output 為 X (unknown)
這是新手最常遇到的問題，可以先檢查看看是不是coding style 不良

>常見不良 coding style 
1. 訊號重複賦值、在多個地方被賦值
2. 在 always(*) 使用了 <=
3. 在 always(posedge clk) 使用了 = 

如果確定沒有 coding style 疑慮，可以懷疑是否 01 模擬遇上瑕疵，功能性本來就有錯誤，但是未被發現\
可以嘗試
1. 人工掃過 CODE 一遍看看有沒有寫錯的地方，像是忘記加條件式 if(in_valid) 造成吃進 X 訊號，或是自己作死為了省面積亂拔 reset
2. 用其他模擬軟體跑 01 ，像是 irun , xrun

如果這些方法都還是解不掉，可以嘗試帶著筆電前往土地公廟


#### 2. output 為 Z (high impedance)
這個問題在前面幾個 lab 理當不會碰到，通常是 final proj CPU_reg 才可能碰上。

1. 先確定合成 tcl 有加入 don't touch 約束（助教會弄好才對） 
2. 確定沒有將指定 reg 和其他同性質訊號對接
```verilog
reg [15:0] CPU_reg_0 ;
reg [15:0] CPU_reg_1 ;
reg [15:0] CPU_reg_2 ;
reg [15:0] CPU_reg_3 ;
reg [15:0] reg_array [0:3] ;

always @(*) begin
    reg_array[0] = CPU_reg_0 ;
    reg_array[1] = CPU_reg_1 ;
    reg_array[2] = CPU_reg_2 ;
    reg_array[3] = CPU_reg_3 ;
end
```

像是這種情況，就會造成有兩個訊號等價，導致 CPU_reg_N 被優化掉變成 Z 。


#### 3. output 為 錯誤數值
01 順利通過，但 03 出錯，說明 02 合成出來的電路和 01_RTL 不等價，造成 03 出現錯誤。
1. 確認所有 BIT 都是 0 或 1 的數值，沒有 Z 。 （ 有 Z 就是被共用了，移動到上面的解法 )
2. 確認沒有用不良的 coding style。
3. 沒有用奇技淫巧，例如 always @(posedge in_valid)這種邪門歪道的寫法。
4. 確認 03 模擬過程中沒有跳出任何 timing violation 。
5. for 迴圈和 generate 回圈都收斂，沒有遇到無限迴圈造成合成器誤解。

這些都還是解不掉，再次請您移步至土地公廟。


### 總結
03 error 最棘手的問題就是電路寫錯，但是 01 沒有驗出來，傻傻地以為是 coding style 問題，改半天依然沒有解決。

03 error 就像癌症一樣，沒辦法預知什麼時候會遇上，只能期望土地公庇佑，但可以有脈絡的預防。

特別是像 LAB5 / Mid proj / Final proj 這種複雜的專案，電路規模巨大無比，寫的時候一不小心就埋地雷，特別容易造成合成器誤判，預防的方法也很簡單，當 01 通過一筆測資時，此時電路只完成一小部分，就先跑 02, 03 ，確保 03 模擬出來的結果和 01_RTL 一致，再繼續往下做。

也就是說\
假設 01 通過 PAT 0 且 PAT1 錯誤，錯誤值為 6ABB ，那麼 03 也必須通過 PAT 0 且 PAT1 錯誤，且錯誤值為 6ABB。

如此可以及早發現 03 問題，並且在情況較為簡單的情況下抓出錯誤。