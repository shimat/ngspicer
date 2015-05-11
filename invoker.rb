#!ruby

require 'rubygems'
require 'ffi'

module Invoker
  extend FFI::Library
  ffi_lib 'ngspice.dll'

  callback :SendChar, [:string, :int, :pointer], :int
  callback :SendStat, [:string, :int, :pointer], :int
  callback :ControlledExit, [:int, :bool, :bool, :int, :pointer], :int
  callback :SendData, [:pointer, :int, :int, :pointer], :int
  callback :SendInitData, [:pointer, :int, :pointer], :int
  callback :BGThreadRunning, [:bool, :int, :pointer], :int

  attach_function :ngSpice_Init, [:SendChar, :SendStat, :ControlledExit,
                    :SendData, :SendInitData, :BGThreadRunning, :pointer], :int
  attach_function :ngSpice_Command, [:string], :int
  attach_function :ngSpice_Circ, [:pointer], :int
  attach_function :ngSpice_running, [ ], :bool
end