---
title: プログラミング言語処理系を作りたい
---

大体タイトルの通りです。
<https://github.com/takoeight0821/malgo>で雑に作っていたけど、雑すぎて行き詰ったので細かい所を考える。

やること
---

1. 途中まで読んで投げている「最新コンパイラ構成技法」を最後まで読む&実装する

虎本では書き換え可能な変数を使うことを前提とした解説も多いので、HaskellよりSMLやOCamlの方が楽そう。

字句解析や構文解析はわりと魔境なので、S式でやっていく。
queen.tigはこんな感じ

```lisp
; 8クイーン問題を解くプログラム
(let (
  (var N 8)
  (type intArray (array int))
  (var row (intArray N 0))
  (var col (intArray N 0))
  (var diag1 (intArray (+ N (- N 1)) 0))
  (var diag2 (intArray (+ N (- N 1)) 0))

  (function (printboard)
    (for (i 0 (- N 1))
      (for (j 0 (- N 1))
        (print (if (= (aref col i) j)
                   " O"
                   " .")))
      (print "\n"))
    (print "\n"))
  (function (try c:int)
    (if (= c N)
        (printboard)
        (for (r 0 (- N 1))
          (if (and (= row[r] 0) (= diag1[(+ r c)] 0) (= diag2[(- (+ r 7) c)] 0))
              (do (set row[r] 1) (set diag1[(+ r c)] 1) (set diag2[(- (+ r 7) c)] 1)
                  (set col[c] r)
                  (try (+ c 1))
                  (set row[r] 0) (set diag1[(+ r c)] 1) (set diag2[(- (+ r 7) c)] 0))))))
  )
  (try 0))
```

代入(set)周りはCommon Lispのsetfを参考にした。これは後々変えるかも。(:=にするなど)

merge.tigはこんな感じ

```lisp
(let ((type any {any:int})
      (var buffer (getchar))
      (function (readint:int any:any)
        (let ((var i 0)
              (function (isdigit:int s:string)
                (and (>= (ord buffer) (ord "0")) (<= (ord buffer) (ord "9")))))
          (while (or (= buffer " ") (= buffer "\n"))
            (set buffer (getchar)))
          (set any.any (isdigit buffer))
          (while (isdigit buffer)
            (set i (+ (* i 10) (- (ord buffer) (ord "0"))))
            (set buffer (getchar)))))
      (type list {first:int rest:list})
      (funtion (readlist:list)
        (let ((var any any{any 0})
              (var i (readint any)))
          (if any.any
            list{first i, rest (readlist)}
            (do (set buffer (getchar))
                nil))))
;; ...などなど
```
