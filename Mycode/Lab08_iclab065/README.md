### Lab08 實驗概述
1. System Verilog 練手 RTL Project
2. 題目是飲料機，涉及狀態機、簡易邏輯運算、DRAM讀取與寫回

### 實驗評論
1. 這個題目是很好的練習題材，可以練習使用 System Verilog 的功能，像是 enumerate, structure, union , Package...，還有奠定物件導向的 struct，以及獨有的 interface 
2. 配合 Lab9 練習 System Verilog 驗證功能以及覆蓋率計算。



### Tips

1. bridge 和 bev(飲料機) 分開來合成，所以會有0.5T的 timing 被限縮，可以將電路移到 bridge
2. bridge 面積可以非常小，不需要用狀態機來設計，只需要能順利寫、讀 DRAM 即可。
3. 不要為了壓面積做過於極端的操作。
4. 題目簡易，所有人的 perf 都不會差太遠。
5. clock period 可以達到2.0ns 甚至更低，這種情況下部分 mux 面積會比 reg 大，尤其是 bridge 的部分能用的 timing 只有 0.5T ，因此可以嘗試使用 reg 取代位於 input/output 的 mux 。

### 其他叮囑
1. 飲料機這個題目算是經典老題目，但 Spec 可能有新增條件，使用現成 pattern 要額外留意以免疏漏。