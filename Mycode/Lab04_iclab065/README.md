### Lab04實驗概述
1. 設計一個 CNN 加速器，涉及浮點數運算所以需要使用 Design hardware。
2. 內容包含
   a. Convolution
   b. Padding
   c. Max Pooling
   d. Fully Connected
   e. Normalization
   f. Activation Function
   > Soft plus
   > Sigmoid
   > Tanh
   > ReLU

   g. Flatten

### 實驗評論

難度稍高，怎麼切 pipeline 需要反覆嘗試，追求高分需要花很多時間想算法。

### Tips

1. Shift_reg 配合加法樹實現卷積運算可以達到不錯的面積表現，這次實驗評分標準沒有考慮功耗，值得嘗試。
2. 想要縮短CC數可以在乘法器的地方多切幾道，不用擔心面積問題，因為是IEEE-754浮點數，運算始終保持 32 bits，並不會因為乘法所以變成 64 bits。
3. Hyperbolic Functions 有很多公式，助教提供的不見得是最好的，換一個公式就可以共用不少資源。
4. 有時候網路很卡，可以在一開始就把 Design hardware 的手冊下載下來，這樣就不會有延遲了。
5. 浮點數IP不論加減乘除還是指數對數都很花資源，盡可能共用。
6. 用 excel 排程是個不錯的方法。

### 其他叮囑
1. 別花太多時間猶豫架構，用脈動陣列還是乘法器和加法樹下好離手，控制部份最簡單暴力的方法就是開一個超大 cnt 控制每一個 cycle 要做哪一些事情。