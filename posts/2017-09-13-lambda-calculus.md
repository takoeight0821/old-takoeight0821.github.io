---
title: AN INTRODUCTION TO FUNCTIONAL PROGRAMMING LANGUAGE THROUGH LAMBDA CALCLUSを読んでいる
---

図書館で見つけたので読んでいる。
そのメモとか色々。

## def
`def id = λx.x`のようなシンタックスシュガーが出てくる。
ラムダ計算の項に変換すると、`(λid.[後続するコード] λx.x)`
let多相とかいろいろあるので分けてた方がいいときもある。

Haskellでラムダ計算インタプリタ実装の機運が高まってきた。
続きは後々追記する。
