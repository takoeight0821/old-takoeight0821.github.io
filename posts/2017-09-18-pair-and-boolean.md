---
title: ラムダ計算でのペアと真偽値の表現
---

<p>ラムダ計算のもろもろを改めて文書化していこうという気持ちがあり、まずはペアと真偽値から始める。 Haskellが読めるとうれしい。</p>
<p>ラムダ計算でデータ構造を扱うには、そのデータ構造をラムダ項に変換する必要がある。 値コンストラクタを関数に置き換えることで、この変換を行うことができる。</p>
<h1 id="ペア">ペア</h1>
<p>例えばペアは以下のように定義する。</p>
<pre><code>pair = λfirst.λsecond.λfunc.func first second</code></pre>
<p>Haskellで同等の関数を書くと以下のようになる。</p>
<div class="sourceCode"><pre class="sourceCode haskell"><code class="sourceCode haskell">pair first second <span class="fu">=</span> \func <span class="ot">-&gt;</span> func first second</code></pre></div>
<p>Haskellのペア(2値のタプル)を上で定義したペアに変換する関数は以下のようになる。</p>
<div class="sourceCode"><pre class="sourceCode haskell"><code class="sourceCode haskell">trans (x, y) <span class="fu">=</span> pair x y</code></pre></div>
<p>中置演算子の前置記法を使うと、置き換えであることがよく分かる。</p>
<div class="sourceCode"><pre class="sourceCode haskell"><code class="sourceCode haskell">trans ((,) x y) <span class="fu">=</span> pair x y</code></pre></div>
<p>ペアから値を取り出すには単に一つ目の引数(あるいは二つ目の引数)を返す関数を定義して、ペアに渡せばいい。</p>
<pre><code>fst = λfirst.λsecond.first
snd = λfirst.λsecond.second

pair a b fst == (λx.λy.λf.f x y) a b fst
             == (λf.f a b) (λx.λy.x)
             == (λx.λy.x) a b
             == (λy.a) b
             == a</code></pre>
<p>前置版を書くこともできる</p>
<pre><code>fst' = λp. p fst
snd' = λp. p snd

fst' (pair a b) == pair a b fst == a</code></pre>
<h1 id="真偽値">真偽値</h1>
<p>真偽値は、TrueかFalseの単純な値である。 値コンストラクタを関数に置き換える戦略では、真偽値をうまく扱えないように見える。</p>
<p>この問題は一旦置いておいて、if式について考えてみる。</p>
<p><code>if True then x else y</code>は<code>x</code>を返す。<code>if False then x else y</code>は<code>y</code>を返す。</p>
<p><code>if True ~</code>はペアのfstに、<code>if False ~</code>はペアのsndに似ている。</p>
<p>ここで、ペアをif式として使えるかを考えると</p>
<pre><code>if = λc.λt.λf.pair t f c
true = fst
false = snd

if true x y == pair x y true
            == pair x y fst
            == fst x y
            == x
if false x y == pair x y false
             == pair x y snd
             == snd x y
             == y</code></pre>
<p>うまく動いた。</p>
<p>if関数は次のように書くこともできる。</p>
<pre><code>if = λc.λt.λf. c t f</code></pre>
<p>つまり、ifは必要ない!! とはいっても、ifがあると可読性が上がる。</p>
<p>not, and, orなどの論理演算については後々書く。</p>
