#!/usr/bin/ruby
# coding: utf-8

require 'fileutils'

class HatebloMathText
  def initialize(md_doc)
    @target_text = []
    @file_name = File.basename(md_doc) + '.hatena'
    File.open(md_doc, 'r:utf-8') do |f|
      f.read.split(/(\n)(?=\\begin{(equation|align)})/).each do |block|
        if block =~ /\\begin{align}/
          block.split(/(?<=\\end{align})\n/).each do |inner|
            @target_text.push(inner)
          end
        elsif block =~ /\\begin{equation}/
          block.split(/(?<=\\end{equation})\n/).each do |inner|
            @target_text.push(inner)
          end
        else
          block.split("\n").each do |line|
            @target_text.push(line)
          end
        end
      end
    end
  end

  # debug 用の関数, 処理後のテキストを表示
  def print_line
    check_and_replace
    @target_text.each do |line|
      puts line
      puts '--------------------------------------'
    end
  end

  # $...$ を [tex:{...}] に
  def replace_dollars(line)
    return unless line =~ /\$*\$/
    line.sub!(/\$/, '[tex:{')
    line.sub!(/\$/, '}]')
    replace_dollars(line)
  end

  # \begin{equation} .. \end{equation} を [tex:{\begin{equation}...\end{equation}}] に
  def replace_environment(line)
    line.insert(0, '[tex:{') if line =~ /\\begin{(equation|align)}/
    line.insert(-1, '}]') if line =~ /\\end{(equation|align)}/
  end

  # _ と ^ を \_, \^ にする
  def escape_symbol(line)
    return if line !~ /\[tex:{.*}\]/ && line !~ /\\begin{(equation|align)}/
    line.gsub!(/(?<!\\)\^/, '\^')
    line.gsub!(/(?<!\\)\_/, '\_')
    line.gsub!(/\\\\/, '\\\\\\\\\\') # なんでこんなに書かないといけないのかわかっていない
  end

  # 置換を実行
  def check_and_replace
    @target_text.delete('align')
    @target_text.delete('equation')
    @target_text.each do |line|
      replace_dollars(line)
      replace_environment(line)
      escape_symbol(line)
    end
  end

  # ファイル書き込み
  def write_text
    check_and_replace
    File.open(@file_name, 'w') do |f|
      @target_text.each do |line|
        f.write(line)
        f.write("\n")
      end
    end
  end
end

# main

if __FILE__ == $0
  target = HatebloMathText.new(ARGV[0])
  target.write_text
end
