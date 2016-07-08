#!/usr/bin/ruby
# coding: utf-8

require 'find'
require 'fileutils'

class HatebloText
  def initialize(md_doc)
    @target_text = []
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

  def check_and_replace
    @target_text.each do |line|
      replace_dollars(line)
      replace_environment(line)
    end
  end
end

target = HatebloText.new(ARGV[0])
target.print_line
