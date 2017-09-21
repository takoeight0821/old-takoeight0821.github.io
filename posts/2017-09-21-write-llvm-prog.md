---
title: LLVM IRでプログラムを書く Hello world編
---

<p>LLVM IRでHello worldを書く話です。 深夜のノリで書きました。</p>
<h2 id="基本の書き方とコンパイル方法">基本の書き方とコンパイル方法</h2>
<p>拡張子は<code>.ll</code>を使用します。<code>main.ll</code>のようなファイルを作成し、<code>clang main.ll</code>を実行するとコンパイルされます。</p>
<h3 id="関数定義とエントリポイント">関数定義とエントリポイント</h3>
<p>関数の定義は<code>define &lt;返り値の型&gt; @&lt;関数名&gt; ([引数の型のリスト]) { ... }</code>です。</p>
<p>プログラムのエントリポイントはCと同様main関数になります。main関数の返り値が終了ステータスになる点も同様です。</p>
<p>いわゆる「何もしないプログラム」を書くと以下のようになります。</p>
<div class="sourceCode"><pre class="sourceCode llvm"><code class="sourceCode llvm"><span class="kw">define</span> <span class="dt">i32</span> <span class="fu">@main</span>() {
    <span class="kw">ret</span> <span class="dt">i32</span> <span class="dv">0</span>
}</code></pre></div>
<p>return命令は<code>ret &lt;返り値の型&gt; &lt;返り値&gt;</code>になります。 LLVM IRでは多くの場合でこのように型を明記する必要があります。</p>
<h2 id="文字列定数の宣言">文字列定数の宣言</h2>
<p>グローバル(変数|定数)は、<code>@&lt;変数名&gt; = (global | constant) &lt;型&gt; [初期値]</code>で宣言します。</p>
<p>グローバル変数はポインタ値を保持します。 C風の擬似コード<code>char** hello = &amp;&quot;Hello world&quot;;</code>をLLVM IRで書くと以下のようになります。</p>
<div class="sourceCode"><pre class="sourceCode llvm"><code class="sourceCode llvm"><span class="fu">@hello</span> = <span class="kw">constant</span> [<span class="dv">12</span> x <span class="dt">i8</span>] c<span class="st">&quot;Hello world\00&quot;</span></code></pre></div>
<p><code>[12 x i8]</code>は、i8型(char型)の要素を12個持つ配列を意味する型です。</p>
<h2 id="標準cライブラリ関数の利用">標準Cライブラリ関数の利用</h2>
<p>外部関数の宣言は<code>declare &lt;返り値の型&gt; @&lt;関数名&gt; ([引数の型のリスト])</code>です。 標準Cライブラリの関数は、外部関数の宣言のみで利用できます。</p>
<p>たとえば、<code>int puts(char*)</code>の宣言は以下のようになります。</p>
<div class="sourceCode"><pre class="sourceCode llvm"><code class="sourceCode llvm"><span class="kw">declare</span> <span class="fu">@puts</span>(<span class="dt">i8</span>*)</code></pre></div>
<h2 id="ポインタアクセスとhello-world">ポインタアクセスとHello world</h2>
<p>ポインタ値から値を取り出すには<code>getelementptr &lt;指している値の型&gt;, &lt;指している値の型&gt;* &lt;ポインタ値&gt;, &lt;インデックス1&gt;, &lt;インデックス2&gt;, ...</code>を使います。 これはCで書くと、<code>&amp;&lt;ポインタ値&gt;[&lt;インデックス1&gt;][&lt;インデックス2&gt;]...</code>のような意味です。</p>
<p>先ほどの擬似コード<code>char** hello = &amp;&quot;Hello world&quot;;</code>から’H’へのポインタを取り出すことは、<code>&amp;hello[0][0]</code>と書けばいいので、<code>@hello</code>からi8*型のポインタを取り出すコードは以下のようになります。</p>
<div class="sourceCode"><pre class="sourceCode llvm"><code class="sourceCode llvm"><span class="kw">define</span> <span class="dt">i32</span> <span class="fu">@main</span>() {
  <span class="fu">%helloptr</span> = <span class="kw">getelementptr</span> [<span class="dv">12</span> x <span class="dt">i8</span>], [<span class="dv">12</span> x <span class="dt">i8</span>]* <span class="fu">@hello</span>, <span class="dt">i32</span> <span class="dv">0</span>, <span class="dt">i32</span> <span class="dv">0</span>
  <span class="kw">ret</span> <span class="dt">i32</span> <span class="dv">0</span>
}</code></pre></div>
<p>ここまでできてしまえば後はputsを呼び出すだけです。ここまで書いてきたすべてのコードと合わせると以下のようになります。</p>
<div class="sourceCode"><pre class="sourceCode llvm"><code class="sourceCode llvm"><span class="fu">@hello</span> = <span class="kw">constant</span> [<span class="dv">12</span> x <span class="dt">i8</span>] c<span class="st">&quot;Hello world\00&quot;</span>

<span class="kw">define</span> <span class="dt">i32</span> <span class="fu">@main</span>() {
       <span class="fu">%helloptr</span> = <span class="kw">getelementptr</span> [<span class="dv">12</span> x <span class="dt">i8</span>], [<span class="dv">12</span> x <span class="dt">i8</span>]* <span class="fu">@hello</span>, <span class="dt">i32</span> <span class="dv">0</span>, <span class="dt">i32</span> <span class="dv">0</span>
       <span class="kw">call</span> <span class="dt">i32</span> <span class="fu">@puts</span>(<span class="dt">i8</span>* <span class="fu">%helloptr</span>)
       <span class="kw">ret</span> <span class="dt">i32</span> <span class="dv">0</span>
}

<span class="kw">declare</span> <span class="dt">i32</span> <span class="fu">@puts</span>(<span class="dt">i8</span>*)</code></pre></div>
<p>…正直めちゃくちゃややこしい。 アセンブラよりは簡単ですね![要出典]</p>
