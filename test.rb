#!ruby

require './ngspice.rb'
require 'gnuplot'

Circuit_1 = <<"EOS"
* title
Vdd a 0 dc
R1 a 0 10ohm
.dc Vdd 0V 10V 1V
.end
EOS

#def Ngspice::send_char(str, id, user_data)
#  puts(str)
#end

Ngspice.init

Ngspice.circ(Circuit_1)
Ngspice.command('run')

result = Ngspice.get_result
pp result

Gnuplot.open do |gp|
  voltage = result.collect{|k| k['v-sweep']}
  current = result.collect{|k| k['a']}
  Gnuplot::Plot.new(gp) do |plot|
    plot.title('voltage - current')
    #plot.size('ratio 1 1')
    plot.xlabel('voltage')
    plot.ylabel('current')
    plot.data << Gnuplot::DataSet.new([voltage]){|ds| ds.with = 'lines'}
    plot.data << Gnuplot::DataSet.new([current]){|ds| ds.with = 'lines'}
  end
end

=begin
MySendChar = Proc.new{ |str, id, userData|
  puts(str)
}

Invoker.ngSpice_Init(MySendChar, nil, nil, nil, nil, nil, nil)

circuit = <<"EOS"
* title
Vdd a 0 dc
R1 a 0 10ohm
.dc Vdd 0V 10V 0.1V
.end
EOS

Invoker.ngSpice_CircEx(circuit)

#Invoker.ngSpice_Command("listing")
Invoker.ngSpice_Command("set nomoremode")
Invoker.ngSpice_Command("run")
Invoker.ngSpice_Command("print all")
=end
