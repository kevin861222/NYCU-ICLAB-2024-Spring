### Lab02實驗概述

設計 sequential circuit，題目是 Enigma Machine ，加密的部分很直觀，但解密有點小複雜，看了很久才看懂，clock period 是固定的，performance 由 Area 決定。

### 實驗評論

這個 Lab 很吃邏輯，要怎麼用硬體實現 key-find-value 以及 value-find-key 是門學問，這部分面積優化我沒有做的很好。

### Tips

1. 不論是 key-find-value 或是 value-find-key ，合成出來都是同樣數量的比較器以及多工器，所以就大膽的用 for 回圈搭配比較器實現吧。

```verilog
//* inv_rotor_B_out_temp - combinational
integer lp_irbt ; //! for loop Parameter
always @(*) begin:Inv_rotor_B_out_temp
	inv_rotor_B_out_temp = 0 ;
	for (lp_irbt = 0;lp_irbt<=63 ;lp_irbt = lp_irbt+1 ) begin
		if (rotor_B[lp_irbt]==reflactor_out) begin
			inv_rotor_B_out_temp = lp_irbt ;
		end
	end
end
```

2. 和 Lab1 一樣，盡可能共用硬體，以及縮短 critical path 上的運算。
3. 每一輪運算後 rotor 順序會改變，但不需要真的實現出交換的功能，可以用一個查找表來替代，也就是我程式中的 mode_map，這樣面積會節省非常多。
4. rotor 即是 1-to-1 LUT，可以用 1-D array 實現，資料由 pattern 輸入，在運算開始前存入。
5. 雖然這次上課在教怎麼設計狀態機，但是我的設計中並沒有狀態機，面積小了不少。
6. 多和隊友討論。
7. 提前做完可以開始看 Pattern 怎麼寫，為了Lab3做準備

