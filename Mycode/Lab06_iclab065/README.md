### Lab06實驗概述
1. 硬體實現 Huffman coding。
2. 練習設計 Soft IP 


### 實驗評論
1. 算法非常軟體，腦袋有點轉不太過來。
2. 要實現出來沒什麼難度。
3. latency 可以壓到 1T。


### Tips

1. 用插入排序法準沒錯。
   >https://medium.com/@ollieeryo/insertion-sort-%E6%8F%92%E5%85%A5%E6%8E%92%E5%BA%8F%E6%B3%95-c215ae516a7a

2. Huffman coding需要使用穩定排序法，無法使用 Lab1 的排序法，雖然那是最優解，但是他非穩定。
   > 如果一個排序法，在兩個元素的排列順序相等時，若有辦法按原本在陣列中的順序排列，就說它屬於穩定排序（stable）；若做不到，則屬於不穩定排序（unstable）。

3. input/output 都還有 0.5T 的 timing 可以偷
4. 收到第一筆資料就可以先排序了


### 其他叮囑
1. 早點做完早點開始念期中考。
