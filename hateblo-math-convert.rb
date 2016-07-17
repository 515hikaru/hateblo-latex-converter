#!/usr/bin/ruby
# coding: utf-8

require 'fileutils'
require 'optparse'

class HatebloMathText
  def initialize(md_doc, hatena)
    @target_text = []
    @hatena = hatena
    @file_name = File.basename(md_doc) + '.hatena'
    File.open(md_doc, 'r:utf-8') do |f|
      content = f.each_line
      split_file(content)
    end
    check_and_replace
  end

  def split_file(file)
    file.each_with_index do |item, _i|
      split_dollar = item.split(/(\$*\$)/)
      join_dollars(split_dollar)
    end
  end

  def join_dollars(split_file)
    split_file.each_with_index do |item, i|
      next if i >= 1 && split_file[i - 1] == '$' && split_file[i + 1] == '$'
      next if i >= 2 && split_file[i - 2] == '$'
      if item != '$'
        # @target_text.push(item)
        puts item
      else
        dollar = [item, split_file[i + 1], split_file[i + 2]]
        puts dollar
        # @target_text.push(dollar.join(''))
      end
    end
  end

  def split_text_and_mathblock(block, environment = 'none')
    if environment == 'none'
      if block =~ /\$*\$/
        tmp_array = block.split(/(\$)/)
        tmp_array.each_with_index do |item, i|
          next if i >= 1 && tmp_array[i - 1] == '$' && tmp_array[i + 1] == '$'
          next if i >= 2 && tmp_array[i - 2] == '$'
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
    line.gsub!(/(?<!\\)\^/, '\^') unless @hatena
    line.gsub!(/(?<!\\)\_/, '\_') unless @hatena
    line.gsub!(/\[/, '\[')
    line.gsub!(/\]/, '\]')
    line.gsub!(/\\\\/, '\\\\\\\\\\') # なんでこんなに書かないといけないのかわかっていない
  end

  # 置換を実行
  def check_and_replace
    @target_text.delete('align')
    @target_text.delete('equation')
    @target_text.each do |line|
      next unless line =~ /\\begin{.*}/ || line =~ /\$*\$/
      puts '-------------------------------------------------------'
      puts line
      puts '-------------------------------------------------------'
      escape_symbol(line)
      replace_dollars(line)
      replace_environment(line)
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
  option = {}
  OptionParser.new do |opt|
    opt.on('-q', '--hatena', 'はてな記法用のエスケープ') do |v|
      option[:hatena] = v
    end
    opt.parse!(ARGV)
  end
  target = HatebloMathText.new(ARGV[0], option[:hatena])
  # target.print_line
  target.write_text
end
