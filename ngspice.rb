#!ruby

require 'pp'
require './invoker.rb'

module Ngspice

  @@send_char_proc = Proc.new{ |str, id, user_data|
    if @@send_char_buffer
      @@send_char_buffer << str
    else
      send_char(str, id, user_data)
    end
  }
  @@send_char_buffer = nil

  module_function
  def init
    Invoker.ngSpice_Init(@@send_char_proc, nil, nil, nil, nil, nil, nil)
    Invoker.ngSpice_Command('set nomoremode')
  end

  def send_char(str, id, user_data)
    puts(str)
  end

  def circ(circuit_string)
    # 行ごとの文字列に分割し、それぞれの先頭ポインタを持つ配列(char**)にする
    lines = circuit_string.split("\n")
    pointerArray = FFI::MemoryPointer.new(:pointer, lines.size + 1)
    strPointers = lines.collect { |s| FFI::MemoryPointer.from_string(s) }
    strPointers << nil # NULLの番兵
    pointerArray.put_array_of_pointer(0, strPointers)

    Invoker.ngSpice_Circ(pointerArray)
  end

  def command(str)
    Invoker.ngSpice_Command(str)
  end

  def get_result
    @@send_char_buffer = []
    begin
      begin
        Invoker.ngSpice_Command('print all')
      rescue => ex
        ex.to_s
      end
      all_tokens = @@send_char_buffer.collect{|line| line.split() }
      header = all_tokens.find_all{|t| t.size >= 2 && t[1] == 'Index' }.first
      values = all_tokens.find_all{|t| t.size >= 2 && t[1] =~ /\d+/ }
      data = []
      values.each do |line_values|
        line = {}
        for i in 1...header.size
          line[header[i]] = line_values[i]
        end
        data << line
      end
      data
    ensure
      @@send_char_buffer = nil
    end
  end

end