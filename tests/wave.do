onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /tb_cpu/dev_to_test/CU/clk
add wave -noupdate /tb_cpu/dev_to_test/Tn
add wave -noupdate /tb_cpu/dev_to_test/CU/Opcode
add wave -noupdate /tb_cpu/dev_to_test/CU/current_state
add wave -noupdate -radix unsigned /tb_cpu/dev_to_test/CU/current_instruction
add wave -noupdate -radix unsigned /tb_cpu/dev_to_test/CU/registerDNum
add wave -noupdate -radix unsigned /tb_cpu/dev_to_test/CU/actualRegister
add wave -noupdate -radix unsigned /tb_cpu/dev_to_test/CU/SelA
add wave -noupdate -radix decimal /tb_cpu/dev_to_test/CU/SelB
add wave -noupdate -radix decimal /tb_cpu/dev_to_test/CU/constantValue
add wave -noupdate /tb_cpu/dev_to_test/CU/constantValue
add wave -noupdate /tb_cpu/dev_to_test/ALU0/K
add wave -noupdate -divider GPR
add wave -noupdate -label R5 /tb_cpu/dev_to_test/AR/Registers(5)
add wave -noupdate -label R10 /tb_cpu/dev_to_test/AR/Registers(10)
add wave -noupdate -label R16 -radix unsigned /tb_cpu/dev_to_test/AR/Registers(16)
add wave -noupdate -label R17 -radix unsigned /tb_cpu/dev_to_test/AR/Registers(17)
add wave -noupdate -label R18 -radix unsigned /tb_cpu/dev_to_test/AR/Registers(18)
add wave -noupdate -label R19 -radix unsigned /tb_cpu/dev_to_test/AR/Registers(19)
add wave -noupdate -label R20 /tb_cpu/dev_to_test/AR/Registers(20)
add wave -noupdate -label R22 /tb_cpu/dev_to_test/AR/Registers(22)
add wave -noupdate /tb_cpu/dev_to_test/AR/Registers
add wave -noupdate -divider TIMER
add wave -noupdate -label TCNT -radix binary /tb_cpu/dev_to_test/AR/Registers(82)
add wave -noupdate -label TCCR /tb_cpu/dev_to_test/AR/Registers(83)
add wave -noupdate -label TIFR /tb_cpu/dev_to_test/AR/Registers(88)
add wave -noupdate -label OCR /tb_cpu/dev_to_test/AR/Registers(92)
add wave -noupdate -divider PORTA
add wave -noupdate -label DDRA /tb_cpu/dev_to_test/AR/Registers(58)
add wave -noupdate -label PORTA /tb_cpu/dev_to_test/AR/Registers(59)
add wave -noupdate -label PINA /tb_cpu/dev_to_test/AR/Registers(57)
add wave -noupdate -divider PORTB
add wave -noupdate -label DDRB /tb_cpu/dev_to_test/AR/Registers(55)
add wave -noupdate -label PINB /tb_cpu/dev_to_test/AR/Registers(54)
add wave -noupdate -label PORTB /tb_cpu/dev_to_test/AR/Registers(56)
add wave -noupdate -divider SREG
add wave -noupdate -label SREG /tb_cpu/dev_to_test/AR/Registers(95)
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 2} {667008 ps} 0} {{Cursor 2} {25131148 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 238
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {0 ps} {3150 ns}
