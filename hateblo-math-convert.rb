#!/usr/bin/ruby
# coding: utf-8

require 'fileutils'
require 'optparse'

class HatebloMathConverter
  def initialize(md_doc, hatena)
    @target_text = []
    @hatena = hatena
    @reg_exp_begin = /\\begin{(equation|align)}/
    @reg_exp_end = /\\end{(equation|align)}/
    @file_name = File.basename(md_doc) + '.hatena'
    File.open(md_doc, 'r:utf-8') do |f|
      content = f.each_line.to_a
      split_inline_and_block(content)
    end
    check_and_replace
  end

  def check_inline_math(line)
    unless line.match(/\$*\$/)
      @target_text.push(line)
      return
    end
    inline_array = line.split(/\$/)
    push_inline_math(inline_array)
  end

  def push_even_math(array)
    array.each.with_index do |_item, i|
      @target_text.push('$' + array[i] + '$') if i.even?
      @target_text.push(array[i]) if i.odd?
    end
  end

  def push_inline_math(array)
    array.each.with_index do |_item, i|
      @target_text.push('$' + array[i] + '$') if i.odd?
      @target_text.push(array[i]) if i.even?
    end
  end

  def split_inline_and_block(content)
    index_get(content)
    make_interval
    content.each_with_index do |item, index|
      next if @interval.include?(index)
      if @block_index.include?(index)
        @target_text.push(make_block(index, @block_index.index(index), content))
      else
        check_inline_math(item)
      end
    end
  end

  def make_block(param, block_index, content)
    block = ''
    until param > @block_index[block_index + 1]
      block += content[param]
      param += 1
    end
    block
  end

  def make_interval
    even = (0..((@block_index.size / 2) - 1)).map { |i| i * 2 }
    @interval = []
    even.each do |i|
      j = @block_index[i] + 1
      until j > @block_index[i + 1]
        @interval.push(j)
        j += 1
      end
    end
  end

  def index_get(content)
    @block_index = []
    content.each.with_index do |item, i|
      @block_index.push(i) if item.match(@reg_exp_begin)
      @block_index.push(i) if item.match(@reg_exp_end)
    end
  end

  def print_target
    @target_text.each do |line|
      print line
    end
  end

  def replace_dollars(line)
    return unless line =~ /\$*\$/
    line.sub!(/^\$/, '[tex:{')
    line.sub!(/\$$/, '}]')
    replace_dollars(line)
  end

  def replace_environment(line)
    line.insert(0, '[tex:{') if line =~ @reg_exp_begin
    line.insert(-1, '}]') if line =~ @reg_exp_end
  end

  def escape_symbol(line)
    line.gsub!(/(?<!\\)\^/, '\^') unless @hatena
    line.gsub!(/(?<!\\)\_/, '\_') unless @hatena
    line.gsub!(/\[/, '\[')
    line.gsub!(/\]/, '\]')
    line.gsub!(/\\\\/, '\\\\\\\\\\') # なんでこんなに書かないといけないのかわかっていない
  end

  def check_and_replace
    @target_text.each do |line|
      next unless line =~ /\\begin{.*}/ || line =~ /\$*\$/
      escape_symbol(line)
      replace_dollars(line)
      replace_environment(line)
    end
  end

  def write_text
    File.open(@file_name, 'w') do |f|
      @target_text.each do |line|
        if line.match(@reg_exp_begin)
          f.print("\n")
          f.print(line)
        elsif line.match(@reg_exp_end)
          f.print(line)
          f.print("\n")
        else
          f.print(line)
        end
      end
    end
  end
end

if __FILE__ == $PROGRAM_NAME
  option = {}
  OptionParser.new do |opt|
    opt.on('-q', '--hatena', 'はてな記法用のエスケープ') do |v|
      option[:hatena] = v
    end
    opt.on('-p', '--print', '変換後の文書を標準出力') do |v|
      option[:print] = v
    end
    opt.parse!(ARGV)
  end
  target = HatebloMathConverter.new(ARGV[0], option[:hatena])
  target = HatebloMathConverter.new(ARGV[0], option[:hatena])
  target.print_target if option[:print]
  target.write_text
end
