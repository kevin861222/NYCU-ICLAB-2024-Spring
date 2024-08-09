### Lab01實驗概述

設計組合電路，運算包含sorting，以及基本加減法、除法，因為還沒有教合成觀念，clock period 是固定的，performance 由 Area 決定。

Pattern 由助教提供，Demo 時 Pat_num 、 seed 不會更改，自己驗證有過 demo 就會過。

### 實驗評論

這個 Lab 很簡單，就是讓大家習慣怎麼操作 server 以及回憶 verilog 語法而已，運算邏輯很簡易，算法上不太能優化，大家的 performance 都會非常接近，由於 design compiler 會將電路優化，同樣的電路用不同寫法合成出來的結果也會不一樣，想拿高分的人必須 try and error 非常多次。

### Tips

1. 先畫架構圖，時間很夠可以畫詳細一點，時間允許的話可以小到連反向器、mux都畫出來，這樣對電路優化會有很大的幫助。
2. 盡可能共用硬體資源，減法部分可以將取二補數的部分獨立出來，改用加法器實現減法功能。

> 若需要計算 n1 - x , n2 - x , n3 - x , n4 - x , n5 - x ，可以先將 x 取一次補數然後再相加來實現運算。

3. 雖然是組合電路，沒有clk，但是還是可以將path長短的觀念考量進來，合成後將 critical path 上的邏輯再次檢視，如果能縮短 path 就能降低面積。
4. 除法的部分可以用 case 爆開，因為有不少數值都不會被 pattern 打到，所以可以刪掉那些 case ，有機會大幅降低面積。
5. Sorting 可以參考 https://bertdobbelaere.github.io/sorting_networks.html 
這是最優解。

6. 不要像我一樣把所有電路寫在同一包 always 裡面，這樣可能會限制 design compiler 發揮，我的架構和算法都和隊友的一樣，但是成效差了一些。

7. 建立好的 coding style ，學習適度的註解。
8. bit數不一定要開剛剛好，有的地方多開面積還會下降，很玄。
9. 可以嘗試不同的括號
> 以 n1 + n2 + n3 + n4 + n5 為例
> 可以嘗試將不同數值放在括號內，像是 
> (n3 + n2) + (n1 + n4) + n5

10. 提前做完可以開始看 Pattern 怎麼寫，為了Lab3做準備


### 其他叮囑
1. 可以先裝 fitten code / copilot 等 AI 輔助工具以及TerosHDL，這些工具對後期大型電路開發很有幫助，請提前熟悉昔他們的操作。
2. 可以熟悉 GitHub 的使用，日後電路規模變大，有找到 pattern 就先贏一半。 
3. 可以在 vscode 上裝 ssh remote 插件，直接用 vscode 連上 server ，大幅提升開發效率。
4. 解決 vpn 一小時斷線一次的問題，只要 vpn 斷線 server 就要重新登入，後續大型電路合成會超過一個小時，所以請儘早解決這個問題。