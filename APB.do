vlib work
vlog MEM_slave.v APB_tb.v APB_master.v APB_Wrapper.v decoder.v Timer_slave.v
vsim -voptargs=+acc work.APB_tb
add wave *
add wave -position insertpoint  \
sim:/APB_tb/DUT/MEM_SLAVE/MEM
add wave -position insertpoint  \
sim:/APB_tb/DUT/MASTER/cs
add wave -position insertpoint  \
sim:/APB_tb/DUT/TIMER/TIMER_VALUE
add wave -position insertpoint  \
sim:/APB_tb/DUT/TIMER/TIMER_RELOAD
add wave -position insertpoint  \
sim:/APB_tb/DUT/TIMER/INT_STATUS
add wave -position insertpoint  \
sim:/APB_tb/DUT/TIMER/TIMER_EN
run -all
#quit -sim