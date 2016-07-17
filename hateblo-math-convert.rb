#!/usr/bin/ruby
# coding: utf-8

require 'fileutils'

class HatebloMathText
  def initialize(md_doc)
    @target_text = []
    @file_name = File.basename(md_doc) + '.hatena'
    File.open(md_doc, 'r:utf-8') do |f|
      f.read.split(/(\n)(?=\\begin{(equation|align)})/).each do |block|
        init_target_text(block)
      end
    end
    check_and_replace
  end

  def split_text_and_mathblock(block, environment = 'none')
    if environment == 'none'
      if block =~ /\$*\$/
        tmp_array = block.split(/(\$)/)
        tmp_array.each_with_index do |item, i|
          if i >= 2
            next if tmp_array[i - 1] == '$' && tmp_array[i + 1] == '$'
            next if tmp_array[i - 2] == '$'
          end
          if item != '$'
            @target_text.push(item)
          else
            dollar = [item, tmp_array[i + 1], tmp_array[i + 2]]
            @target_text.push(dollar.join(''))
          end
        end
      else
        block.split("\n").each do |line|
          @target_text.push(line)
        end
      end
    else
      block.split(/(?<=\\end{#{environment}})\n/).each do |inner|
        @target_text.push(inner)
      end
    end
  end

  def check_has_math_environment(block, env)
    return true if block =~ /\\begin{#{env}}/
    false
  end

  def init_target_text(block)
    if check_has_math_environment(block, 'align')
      split_text_and_mathblock(block, 'align')
    elsif check_has_math_environment(block, 'equation')
      split_text_and_mathblock(block, 'equation')
    else
      split_text_and_mathblock(block)
    end
  end

  # debug 用の関数, 処理後のテキストを表示
  def print_line
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
    line.insert(0, '[tex:{') if line =~ /\\begin{(equation|align)}/
    line.insert(-1, '}]') if line =~ /\\end{(equation|align)}/
  end

  # _ と ^ を \_, \^ にする
  def escape_symbol(line)
    line.gsub!(/(?<!\\)\^/, '\^')
    line.gsub!(/(?<!\\)\_/, '\_')
    line.gsub!(/\[(?!tex:)/, '\[')
    line.gsub!(/(?<!\})\]/, '\]')
    line.gsub!(/\\\\/, '\\\\\\\\\\') # なんでこんなに書かないといけないのかわかっていない
  end

  # 置換を実行
  def check_and_replace
    @target_text.delete('align')
    @target_text.delete('equation')
    @target_text.each do |line|
      next unless line =~ /\\begin{.*}/ || line =~ /\$*\$/
      replace_dollars(line)
      replace_environment(line)
      escape_symbol(line)
    end
  end

  # ファイル書き込み
  def write_text
    File.open(@file_name, 'w') do |f|
      @target_text.each do |line|
        f.write(line)
        f.write("\n")
      end
    end
  end
end

# main

if __FILE__ == $PROGRAM_NAME
  target = HatebloMathText.new(ARGV[0])
  target.print_line
  target.write_text
end
