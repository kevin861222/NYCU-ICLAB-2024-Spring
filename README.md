# NYCU-ICLAB-2024-Spring 修課心得 & 修課指南
> 我正在緩慢更新中
>
> 勘誤 & 疑難雜症歡迎聯繫我 kevin861222@gmail.com
>
> 幫我按 star 是我持續更新的動力

## 資料夾指引
``` bash
+--- ~
|   README.md
|
+---心得
|   |   README.md 
|
+---修課指南
|   |   README.md 
|   |
|   +---最齊全のICLAB準備事項
|   |   |   README.md
|   | 
|   +---Verilog_小知識
|   |   |   README.md    
|   | 
|   +---Verilog_黑魔法
|   |   |   README.md
|   | 
|   +---ICLAB_高分攻略
|   |   |   README.md
|   | 
|   +---03_Violation解法
|   |   |   README.md
|               
\---Mycode
    |   README.md
    +---Lab01
    +---Lab02
    .
    .
    .
```

## 目錄
1. [摘要](#摘要)
2. [課程內容](#課程內容)
3. [實驗總覽](#實驗總覽)
4. [前言](#前言)
5. [背景](#背景)
6. [主觀聲明](#主觀聲明)

## 摘要
##### 該學期資訊
- 課程名稱：積體電路設計實驗 Integrated Circuit Design Laboratory
- 扣除退選全班平均：78.92 分
- 學期初總修課人數：127 人
- 退選人數：38 人
- 調分：約莫 2 分
- 授課語言：英文
>*退選人數是用期末考缺考人數估計*

>*每人調分幅度未必相同，僅供參考*

>*期中期末考無額外加分*

>*部分實驗題目是考古題，通過率提升但 RANK 更競爭*

##### 個人成績資訊
- 原始分數：87.14
- 等第：A+
- 結算名次：23 / 127
  
|      | Lab01  | Lab02 | Lab03 | Lab04 | Lab05 | Lab06 |OT |    MIDTERM PROJECT | MID EXAM |
| ------------|:------:|:-----:|:-----:|:-----:|:-----:|:-----:|:--------------:|:-----:|:-------:|
| Score       |94.74|95.87|100|93.37|66.08|82.12|50|82.07|76.5|
-------------------------
|     | Lab07  | Lab08 | Lab09 | Lab10 Bonus | Lab11 | Lab12 | LAB13|   FINAL PROJECT  | FINAL EXAM |
| ------------|:------:|:-----:|:-----:|:-----:|:-----:|:-----:|:--------------:|:-----:|:-------:|
| Score       |97|40|100|100|98.95|99.37|100|99.3|95.5|

>**代表該次段考平均分數*

##### 初始成績分布
![成績分布長條圖](https://github.com/kevin861222/NYCU-ICLAB-2024-Spring/assets/79128379/5b2c2efd-a4c4-408a-b033-87a21f6b766e)

##### 個人成績長條圖
![grade長條圖](https://github.com/kevin861222/NYCU-ICLAB-2024-Spring/assets/79128379/40c8b7ed-87d4-40f6-8a21-9755878a9d02)

## 課程內容
| Lecture | Topic |
|:--|:--:|
|Lecture01|Cell Based Design Methodology + Verilog Combinational Circuit Programming|
|Lecture02|Finite State Machine + Verilog Sequential Circuit Programming |
|Lecture03|Verification & Simulation + Verilog Test Bench Programming |
|Lecture04|Sequential Circuit Design II (STA + Pipeline) |
|Lecture05|Memory & Coding Style (Memory Compiler + SuperLint)|
|Lecture06|Synthesis Methodology (Design Compiler + IP Design)|
|Lecture07|Timing: Cross Clock Domain + Synthesis Static Time Analysis|
|Lecture08|System Verilog - RTL Design|
|Lecture09|System Verilog - Verification|
|Lecture10|System Verilog - Formal Verification|
|Lecture11|Power Analysis & Low Power Design|
|Lecture12|APR I : From RTL to GDSII|
|Lecture13|APR II: IR-Drop Analysis|

## 實驗總覽
| Lab | Topic | RANK | Pass Rate |
|:--|:--:|:--:|:--:|
|[Lab01](<https://github.com/kevin861222/NYCU-ICLAB-2024-Spring/tree/main/Mycode/Lab01_iclab065> "Mycode/Lab01")|Code Calculator|21|89.76%|
|[Lab02](<https://github.com/kevin861222/NYCU-ICLAB-2024-Spring/tree/main/Mycode/Lab02_iclab065> "Mycode/Lab02")|Enigma Machine|16|85.83%|
|[Lab03](<https://github.com/kevin861222/NYCU-ICLAB-2024-Spring/tree/main/Mycode/Lab03_iclab065> "Mycode/Lab03")|AXI-SPI DataBridge|NA|75.59%|
|[Lab04](<https://github.com/kevin861222/NYCU-ICLAB-2024-Spring/tree/main/Mycode/Lab04_iclab065> "Mycode/Lab04")|Convolution Neural Network|22|74.80%|
|[Lab05](<https://github.com/kevin861222/NYCU-ICLAB-2024-Spring/tree/main/Mycode/Lab05_iclab065> "Mycode/Lab05")|Matrix convolution, max pooling and transposed convolution|15|59.06%|
|[Lab06](<https://github.com/kevin861222/NYCU-ICLAB-2024-Spring/tree/main/Mycode/Lab06_iclab065> "Mycode/Lab06")|Huffman Code Operation|60|77.95%|
|[Lab07](<https://github.com/kevin861222/NYCU-ICLAB-2024-Spring/tree/main/Mycode/Lab07_iclab065> "Mycode/Lab07")|Matrix Multiplication with Clock Domain Crossing|58|74.80%|
|[Lab08](<https://github.com/kevin861222/NYCU-ICLAB-2024-Spring/tree/main/Mycode/Lab08_iclab065> "Mycode/Lab08")|Design: Tea House|NA|66.14%|
|[Lab09](<https://github.com/kevin861222/NYCU-ICLAB-2024-Spring/tree/main/Mycode/Lab09_iclab065> "Mycode/Lab09")|Verification: Tea House|1|66.14%|
|[Lab10](<https://github.com/kevin861222/NYCU-ICLAB-2024-Spring/tree/main/Mycode/Lab10_iclab065> "Mycode/Lab10")|Formal Verification|NA|76.38%|
|[Lab11](<https://github.com/kevin861222/NYCU-ICLAB-2024-Spring/tree/main/Mycode/Lab11_iclab065> "Mycode/Lab11")|Low power design: Siamese Neural Network|4|67.72%|
|[Lab12](<https://github.com/kevin861222/NYCU-ICLAB-2024-Spring/tree/main/Mycode/Lab12_iclab065> "Mycode/Lab12")|APR: Matrix convolution, max pooling and transposed convolution|3|68.50%|
|[Lab13](<https://github.com/kevin861222/NYCU-ICLAB-2024-Spring/tree/main/Mycode/Lab13_iclab065> "Mycode/Lab13")|Train Tour APRII|NA|68.50%|
|[Online Test](<https://github.com/kevin861222/NYCU-ICLAB-2024-Spring/tree/main/Mycode/OT_iclab065> "Mycode/OT")|Infix to prefix convertor and prefix evaluation|NA|2.36%|
|[Midtern Project](<https://github.com/kevin861222/NYCU-ICLAB-2024-Spring/tree/main/Mycode/Midterm_Project_iclab065> "Mycode/MP")|Maze Router Accelerator|53|68.50%|
|[Final Project](<https://github.com/kevin861222/NYCU-ICLAB-2024-Spring/tree/main/Mycode/Final_Project> "Mycode/FP")|single core CPU|3|67.72%|

## 前言
雖然網路上已經有非常非常多關於這門課程的評價以及心得文，但是我覺得我的身份比較特別，再加上這一路上踩過不少別人沒有遇到的坑，所以打算用不同的角度詮釋一下這門課程的價值，也記錄一下不是天才的我是怎麼活過這學期的，姑且算是一個窺視孔，讓有遠大抱負的學弟妹們可以好好衡量自己是否真的準備好了，以及理性的評估這門課程的價值。

## 背景
##### 在 iclab 之前修過哪些課 / 做了哪些準備
- 電子碩-CA 計算機結構
- 電控碩-VLSI 超大型積體電路設計
- 電子碩-SOC 系統晶片設計 
- 電子碩-DIC 數位積體電路
- 資工科碩-AAML 機器學習晶片架構設計
- 電控碩-AFPGA 進階可程式邏輯系統設計與應用
- HDLbits 全刷完
- 2學期 FPGA 應用相關的大學部專題 
- 張添烜教授數位電路與系統的YT影片

##### 技能樹
- 通透 Verilog 
- 略懂 System Verilog <br>
-- 整學期會有兩個 Lab 使用 System Verilog
- 通透 Python <br>
-- Python 在這門課主要是用來產 pattern 或是爆裂 case 
- 略懂 shell script <br>
-- 可以寫腳本加速驗證流程，不用每次都一條一條跑，省超級多時間
- 略懂 Linux 指令 <br>
-- server 很多操作都需要用到這些指令，如果不會這些指令也能通過這門課 <br>
-- Tmux 搭配後台運行能有效率地探索 02 極限 cycle period  (詳見修課指南)<br>

##### 實驗室 / 科系
揭曉開頭所言，我大學不是電機系而是機械系，研究所也不是 ics 實驗室，我只是一個毅力過人的瘋狗，單純覺得數位電路很有挑戰性，再加上源源不絕的興致，秉持著一句富貴險中求，賭上我的愛、勇氣、希望，一路闖關至此，我是真的好累，但我還想往更高的地方前進。

##### 該學期課程
這門課的 Loading 前面都感覺不出來，起初我修了 iclab 以及一門據說很輕鬆的電腦視覺(CV)，但是 Lab5 到期中考、期中 Project 的負擔實在太重，難度一口氣飆升到最高點，Maze routing 讓我差點往生，所以後來把 CV 退掉了。

##### 實驗室負擔
實驗室挺自由，每週有團咪，差不多一個學期我要報告三篇論文，以碩一來說算滿輕鬆了，謝謝天使老闆，讚嘆天使老闆。


## 主觀聲明
>以下是我修完這門課程，出於自身經驗的評價
##### 過譽與否 

這個問題取決於心態，畢竟每年都會有一些題目有些和去年一樣，這些lab是非常好拿分的，但若你能秉持自我訓練的精神，當個苦行僧，自己想架構、算法，不魔改別人的 code ，雖然傻了點不過肯定滿載而歸，在求職面試上都能如魚得水，硬實力和心理素質都能邁向更高層次。

反之，如果每次都無腦看著 best code 的投影片開始刻架構，你能保住髮量和睡眠時間，不過 coding 和設計能力很難跳耀式的提升，你能帶走的就是一些電路觀念還有走完 cell-base 的設計流程，多少有點空虛。

* Lab 1-4 , 7-13 沒參考架構僅看設計tip，
* FP 參考乘法器切多少stage，其餘架構和det算法自己想
* Lab 6 , MP 高度參考前人架構再自己寫一版，收穫大幅下降
* Lab5 傻傻的沒參考歷屆，自己想從頭架構，雖然結果不亮眼，但是學到很多東西也很有成就感，有種不留遺憾的爽，但這個 lab 份量多到會往生，重視生命的學弟妹們建議還是先去看別人的架構

對於參考前人 code 這件事情，我是抱持支持態度的，理解別人的設計也是一種非常重要的軟實力，但是出於時間緊湊，前人的code多半都有註解不夠清楚的問題，再加上很少人會投注時間回頭寫很詳細的README給學弟妹看，能快速吸取的只有一些設計TIP，或是參考 pipeline 切法以及 cycle period ，想要在短時間看懂高人的作品，然後加入自己的想法進一步的優化，更勝於藍，我認為是比較困難的。


##### 燙金的數位ic敲門磚
這門課提供了很好的管道讓非 ics 實驗室的學可以更深入的接觸設計流程，像是 Jasper Gold / innovus 以及真實的 SRAM macro ，18週的課程洗禮也能讓PPA掌控能力大幅提升，加分效果不可忽視。

以求職來說，對於底子好的學生能錦上添花，相信能非常順利找到心儀的工作，反觀血統不純正或是其他系所的學生我認為是必要經歷，因為沒有修過這門課程根本不算真正的瞭解設計晶片，不過目前景氣不存在「修過iclab就能進入XXX公司」的說詞，僅僅只有這門課程的加持是遠遠不夠的，還需要更多歷練才能把這得來不易的敲門磚昇華成入場券。

最後，數位電路工程師本身就是壁壘很高的職位，以我非電子所亦非電機所的背景修完這門課，再加上先前的其他經歷，我也未能肯定自己能因此突破高牆，一些很重視學歷的公司，我連面試機會都拿不到，我也沒有辦法展現我是有實力的學生，但凡事不試試看怎麼知道結果呢，曾經的我很努力，現在的我也還在努力，未來的我也會繼續努力下去，路是自己選的，就算被拒絕了、遇到挫折了也不要輕易放棄，希望螢幕前的你還有所有在這條路追逐夢想的你們都能不忘初衷，念念不忘，必有迴響。


##### 實用性

對於原先底子就很強的學生來說，這門課可能無法進一步的培養你寫 verilog 或是設計硬體的能力，因為再複雜的題目，verilog 的變化性也就那樣，而且這門課程的設計偏向競賽導向，也就是說題目設計以及計算 perf 的公式無法比擬現實遇上的真實問題，很多題目一看就是拿來練手用的，現實中不可能用硬體實現，現實也不會一昧追求 perf 不計 Area 只為了設計出 latency=1 的電路，或是不計 power 瘋狂存取，做出一塊一上電直接燒掉的電路。

但這門課完全可以激起爆發性，要在這麼短的時間內設計出一個 bug-free 的電路，已經很不容易了，還要集成眾多黑魔法才能取得出眾的表現，長時間超頻運轉，思路不斷突破上限，激發出不少潛力，個人非常有感。

再者就是心靈層面的磨練，修課當修心，多跌倒幾次就不怕痛了。

##### 修課的終點
在挑戰 iclab 之前，聽到不少傳聞都說修完這門課就具備工作的能力了，是修課版圖的最後一片拼圖，對於這些說法，我的答案是「大確實」，經過這一學期的洗禮，不論抗壓性或是設計能力都得到了顯著的提升，題目的多樣性也能讓學生接觸到各種層面的問題，一些業界要求的能力(AMBA/CDC/Low power...)在這門課中也都接觸過了，絕對有十足的能力面對職場上的挑戰。

不過修完這門課我感到自己非常渺小，有非常多不足的地方，自己和天才還是有很大一段差距，能進步的空間綽綽有餘，目前所接觸到的知識也只是數位電路中的冰山一角，即便對PPA的掌控游刃有餘，但是對於驗證、以及系統層的設計，都是未曾深入瞭解過的領域。

##### 心境和修為的昇華
這門課可以帶你體會成為大師的三個境界，見自己、見天地、見眾生，講白話一點就是讓你知道自己的不足，從錯誤中學習，和各路高手切磋，激發遇強則強的潛力，隨後悟出門道，成人之美，普渡眾生。

