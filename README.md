# hateblo-latex-converter

MathJax の数式の部分をはてなブログの数式の記法に変換するスクリプト

インライン記法 `$$` を `[tex:{}]` に. ブロック数式 `\begin{equation} ~~ \end{equation}` を `[tex:{\begin{equation} ~~ \end{equation}}]` に変換するなどする.

## 使い方

* ファイル `hateblo-math-convert.rb` に実行権限を与え, パスを通す.
* `hateblo-math-convert.rb hoge.md` と実行すると, 変換後のファイル `hoge.md.hatena` をカレントディレクトリに作成する.
 * 現在複数の引数には対応していない

## 機能

* `$..$` を `[tex:{..}]` に置換
* `\begin{(equation|align)}` は `[tex:{\begin{(equation|align)}` に置換する. `end` は閉じる.
* 改行を表す `\\` は `\\\` に置換する(うまく機能していないかもしれない.)
* `_` は `\_`, `^` は `\^`, `[]` は `\[\]` に置換する.
* `--hatena` オプションによりはてな記法では不要なエスケープをしないように設定できる(注意: Markdown で書かれた文書をはてな記法に変換する機能ではない.)
* `-p`, `--print` オプションにより, 変換後の文書を標準出力へと出力できる.

## TODO

- [] カレントディレクトリでなく引数に指定したファイルがあるディレクトリに `.hatena` ファイルを作るようにする.
- [] 複数引数に対応.

# ライセンス

MIT
