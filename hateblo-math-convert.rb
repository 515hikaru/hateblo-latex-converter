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

  def print_line
    check_and_replace
    @target_text.each do |line|
      puts line
    end
  end

  def replace_dollars(line)
    return unless line =~ /\$*\$/
    line.sub!(/\$/, '[tex:{')
    line.sub!(/\$/, '}]')
    replace_dollars(line)
  end

  def replace_environment(line)
    line.insert(0, '[tex:{') if line =~ /\\begin{.*}/
    line.insert(-2, '}]') if line =~ /\\end{.*}/
  end

  def escape_symbol(line)
    return unless line =~ /[tex:{.*}]/
    line.gsub!(/\^/, '\^')
    line.gsub!(/\_/, '\_')
  end

  def check_and_replace
    @target_text.each do |line|
      replace_dollars(line)
      replace_environment(line)
      escape_symbol(line)
    end
  end

  def write_text
    check_and_replace
    File.open(@file_name, 'w') do |f|
      @target_text.each do |line|
        f.write(line)
      end
    end
  end
end

target = HatebloMathText.new(ARGV[0])
target.write_text
