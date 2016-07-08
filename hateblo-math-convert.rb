#!/usr/bin/ruby
# coding: utf-8

require 'find'
require 'fileutils'

class HatebloMathText
  def initialize(md_doc)
    @target_text = []
    @file_name = File.basename(md_doc) + '.hatena'
    File.open(md_doc, 'r:utf-8') do |f|
      f.each_line do |line|
        @target_text.push(line)
      end
    end
  end

  # debug 用の関数, 処理後のテキストを表示
  def print_line
    check_and_replace
    @target_text.each do |line|
      puts line
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
    line.insert(0, '[tex:{') if line =~ /\\begin{.*}/
    line.insert(-2, '}]') if line =~ /\\end{.*}/
  end

  # _ と ^ を \_, \^ にする
  def escape_symbol(line)
    return unless line =~ /[tex:{.*}]/
    line.gsub!(/\^/, '\^')
    line.gsub!(/\_/, '\_')
  end

  # 置換を実行
  def check_and_replace
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
      end
    end
  end
end

# main

if __FILE__ == $0
  target = HatebloMathText.new(ARGV[0])
  target.write_text
end
