---
title: LLVM IRでプログラムを書く 絶対値関数編
---

LLVM IRで絶対値関数を書く話です。[前回の記事](./2017-09-21-write-llvm-prog.html)の続きです。

## 恒等関数

まず、与えられた整数をそのままオウム返しするだけの関数idを実装します。
C言語で書くと以下のようになります。

```c
int id(int x) {
  return x;
}
```

関数の引数はレジスタ%0から順番に代入されます。
idは引数が1つなので、%0の値をそのまま返します。

以下のコードをlib.llに保存します。

```llvm
define i32 @id(i32) {
  ret i32 %0
}
```

実際に使ってみましょう。以下のコードをmain.cに保存します。

```c
#include <stdio.h>

int id(int x);

int main(void) {
  printf("%d\n", id(42));
}
```

コンパイルは以下のように行います。

```sh
$ clang main.c lib.ll
$ ./a.out
42
```

## 絶対値関数

絶対値関数をCで書くと以下のようになります。

```c
int abs(int x) {
  if (x < 0) {
    return -x;
  } else {
    return x;
  }
}
```

これをLLVM IRで書くと以下のようになります。

```
define i32 @abs(i32) {
entry:
  %cond = icmp slt i32 %0, 0
  %result = alloca i32

  br i1 %cond, label %then, label %else

then:
  %1 = sub i32 0, %0
  store i32 %1, i32* %result
  br label %end

else:
  store i32 %0, i32* %result
  br label %end

end:
  %2 = load i32, i32* %result
  ret i32 %2
}
```

1つずつ追っていきましょう。

まず最初の`entry:`です。
これはラベルと呼ばれ、条件分岐やループの際のジャンプ先として使います。

関数の最初にラベルを書かなかった場合、暗黙的に無名のラベルが挿入されます。
例えば、引数が2つの関数の場合、%0, %1が引数に使われ、%2がこの無名のラベルに使われます。

次に、`%cond = icmp slt i32 %0, 0`です。
icmpは整数比較を行う命令です。sltは比較条件を表します。
以下に比較条件の一覧を示します。

1. eq: 等値
2. ne: 等値でない
3. ugt: 符号なし整数の'>'
4. uge: 符号なし整数の'>='
5. ult: 符号なし整数の'<'
6. sle: 符号あり整数の'<='
7. sgt: 符号あり整数の'>'
8. sge: 符号あり整数の'>='
9. slt: 符号あり整数の'<'
10. sle: 符号あり整数の'<='

`%result = alloca i32`では、結果を保存するためのポインタを用意しています。
LLVM IRではレジスタ(%などから始まる変数)への代入は一度しかできません。
複数回代入する可能性のある変数は、このようにポインタを用意して扱います。

`br i1 %cond, label %then, label %else`はif文の条件分岐に相当します。

`then:`でx<0が真の場合の処理を行います。

`%1 = sub i32 0, %0`では、無名レジスタを使用しています。
無名レジスタは、引数などに使われる、識別子が数字のみのレジスタです。
これは必ず連番になっている必要があります。

`store i32 %1, i32* %result`は、%resultの指す値を%1にする命令です。

`else:`でx<0が偽の場合の処理を行います。
%resultの指す値を%0にしているだけです。

`%2 = load i32, i32* %result`で%resultから結果を読み出し、ret命令で返ります。

abs関数をlib.llに追記して、実際に使ってみましょう。

lib.llの全体を以下に示します。

```llvm
define i32 @id(i32) {
  ret i32 %0
}

define i32 @abs(i32) {
entry:
  %cond = icmp slt i32 %0, 0

  br i1 %cond, label %then, label %else

then:
  %result = sub i32 0, %0
  br label %end

else:
  %result = add i32 0, %0
  br label %end

end:
  ret i32 %result
}
```

main.cの全体を以下に示します。

```c
#include <stdio.h>

int id(int x);
int abs(int x);

int main(void) {
  printf("%d\n", id(42));
  printf("%d\n", abs(-42));
}
```

実行結果は以下のようになります。

```sh
$ clang main.c lib.ll
$ ./a.out
42
42
```