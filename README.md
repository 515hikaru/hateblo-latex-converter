# hateblo-latex-converter

MathJax の数式の部分をはてなブログの数式の記法に変換するスクリプト

インライン記法 `$$` を `[tex:{}]` に. ブロック数式 `\begin{equation} ~~ \end{equation}` を `[tex:{\begin{equation} ~~ \end{equation}}]` に変換するなどする.

# 機能

* `$..$` を `[tex:{..}]` に置換
* `\begin{(equation|align)}` は `[tex:{\begin{(equation|align)}}]` に置換する. `end` は閉じる.
* 改行を表す `\\` は `\\\` に置換する(うまく機能していないかもしれない.)
* `_` は `\_`, `^` は `\^` に置換する. ただし現状では `__hoge__` などの数式は関係ない構文も置換してしまう可能性がある.

# ライセンス

MIT
