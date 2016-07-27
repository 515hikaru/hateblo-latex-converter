# hateblo-latex-converter

MathJax の数式の部分をはてなブログの数式の記法に変換するスクリプト. インライン記法 `$$` を `[tex:{}]` に. ブロック数式 `\begin{equation} ~~ \end{equation}` を `[tex:{\begin{equation} ~~ \end{equation}}]` に変換するなどする.

## 使い方

* ファイル `hateblo-math-convert.rb` に実行権限を与え, パスを通す.
* `hateblo-math-convert.rb hoge.md` と実行すると, 変換後のファイル `hoge.md.hatena` をカレントディレクトリに作成する.
 * 現在複数の引数には対応していない

## 機能

* `$..$` を `[tex:{..}]` に置換
* `\begin{(equation|align)}` は `[tex:{\begin{(equation|align)}` に置換する. `end` は閉じる.
* 改行を表す `\\` は `\\\` に置換する.
* `_` は `\_`, `^` は `\^`, `[]` は `\[\]` に置換する.
* `--hatena` オプションによりはてな記法では不要なエスケープをしないように設定できる(**注意: Markdown で書かれた文書をはてな記法に変換する機能ではない.**)
* `-p`, `--print` オプションにより, 変換後の文書を標準出力へと出力できる.
* オプション一覧は `--help` で見られる.

## 実行例

```markdown
__実数列__のつくる級数 $\displaystyle\sum_{n=1}^\infty a_n$ が収束するとは, 部分和の列 $\displaystyle S_N = \sum_{n=1}^N a_n$ の極限 $\displaystyle\lim_{n \to \infty}S_n$ がある実数 $\alpha$ に収束することを言う.

\begin{align}
a_1 + a_2 =a_3c \\
c - b = a
\end{align}

__こんにちは.__

__こんばんわ__

\begin{equation}
\int_a^b f(x) dx = F(b) - F(a)
\end{equation}
```

この Markdown 文書が次のように変換される:

```
__実数列__のつくる級数 [tex:{\displaystyle\sum\_{n=1}\^\infty a\_n}] が収束するとは, 部分和の列 [tex:{\displaystyle S\_N = \sum\_{n=1}\^N a\_n}] の極限 [tex:{\displaystyle\lim\_{n \to \infty}S\_n}] がある実数 [tex:{\alpha}] に収束することを言う.


[tex:{\begin{align}
a\_1 + a\_2 =a\_3c \\\
c - b = a
\end{align}
}]
__こんにちは.__

__こんばんわ__


[tex:{\begin{equation}
\int\_a\^b f(x) dx = F(b) - F(a)
\end{equation}
}]
```

## TODO

- [x] カレントディレクトリでなく引数に指定したファイルがあるディレクトリに `.hatena` ファイルを作るようにする.
- [ ] 複数引数に対応.


# ライセンス

MIT
