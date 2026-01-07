current_design <top_design_name>  ##top design
current_instance <instance_name> ## if want to do for specific instance within top design

##################################################################################################
                      #1.clock definition(related to clock) 
##################################################################################################
create_clock -name clk -period 10 -waveform {0 5} [get_ports clk]  #clock creation
create_clock -name clk -period 10 -waveform {0 5}     #virtual clock creation
create_clock -name vclk -period 10             #virtual clock creation
create_generated_clock -name clk1 -source [get_ports clk] -divide_by 2 [get_pins FF1/Q]  #generated clock from clk


set_clock_transition -rise 0.2 [get_clocks clk]  ##rise transition of clk
set_clock_transition -fall 0.2 [get_clocks clk]  ##fall transition of clk

##clock transition using max and min
set_clock_transition -rise -max 0.2 [get_clocks clk]  ##rise transition of clk using max
set_clock_transition -fall -min 0.2 [get_clocks clk]  ##fall transition of clk using min

##clock transition (rise, fall, min, max)for all clock in one line
set_clock_transition 0.2 [all_clocks]

###clock uncertainty declaration for intraclock
set_clock_uncertainty 0.1 [get_clocks clk]

#in case of different setup(skew+jitter) and hold(jitter) value
set_clock_uncertainty -setup 0.3 [get_clocks clk]
set_clock_uncertainty -hold  0.2 [get_clocks clk]

###clock uncertainty declaration for interclock setup(skew+jitter) and hold(skew+jitter)
set_clock_uncertainty -from c1 -to c2 -setup 0.5
set_clock_uncertainty -from c1 -to c2 -hold 0.5

###clock uncertainty declaration for interclock setup(skew+jitter) and hold(skew+jitter) using -rising_from to -fall_to
set_clock_uncertainty -rise_from c1 -fall_to c2 0.5

###clock_latency due to source latency
set_clock_latency -source 0.2 [get_clocks clk]
#network latency-applies to rise (for max and min condition) before cts only 
set_clock_latency 0.3 -rise [get_clocks clk]
set_clock_latency 0.3 -fall [get_clocks clk]

##propagated clock
set_propagated_clock


#clock_groups defining
create_clock -period 10 -name c1 -waveform {0 5} [get_ports c1]
create_clock -period 20 -name c2 -waveform {0 12} [get_ports c2]
set_clock_group -logically_exclusive -group c1 -group c2






##################################################################################################
                      #2.port delay declaration (input/output) 
##################################################################################################

set_input_delay -clock clk 0.5 [get_ports I]
set_output_delay -clock clk 0.5 [get_ports O]



##################################################################################################
                      #3. port constraints (driving input and output load)
##################################################################################################
#transition information
set_drive 2.5 [get_ports I]  ##set equivalent resistance of driver
set_driving_cell -lib_cell INVX1 [get_ports I] ## most practical  , for more detail take help with man or help command

set_input_transition -max 0.25 [get_ports I]
set_input_transition -min 0.10 [get_ports I]


#load information
set_port_fanout_number 4 [get_ports O]
set_fanout_load 4.5 [get_ports O]

set_load 0.05 [get_ports O]
set_load -lib_pin INVX1/A [get_ports O] ## most practical  , for more detail take help with man or help command


##################################################################################################
                      #3. timing exception
##################################################################################################

set_false_path -from S1  ###all unique paths starting from S1
set_false_path -through S1 ## cover all paths passing through S1
set_false_path -to S1      ## cover all path terminating at S1
set_false_path -from S1 -to X1 ## COVERS from S1 and passes thorugh X1
set_false_path -from S1 -to X2 ## COVERS from S1 and passes thorugh X2, 

set_false_path -from clk  ## all seq elements triggered by clk  and all input ports constrained with respect to clk


#for more detail take help from man or help command , there are different ways and types of false path declaration

set_false_path -from [get_ports A] -through [get_pins mux1/A] -through [get_pins mux2/A] -to [get_ports B]
set_false_path -through [get_pins mux1/A] -through [get_pins mux2/A]


set_disable_timing -from B to Z11

#for synchronous
set_multicycle_path 2 -setup -from FF1 -to FF2  #for setup
set_multicycle_path 1 -hold -from FF1 -to FF2   #for hold

#for asynchronous clock
set_multicycle_path -from [get_clocks C1] -to [get_clocks C2] -setup 2
set_multicycle_path -from [get_clocks C1] -to [get_clocks C2] -hold 1



##################################################################################################
                      #4. combinational path delay constraint
##################################################################################################
set_max_delay  -from [get_ports I1] -to [get_ports O1] 5  #BOUNDING to have max dealy of 5ns between I1 port to O1
set_min_delay  -from [get_ports I1] -to [get_ports O1] 3  #BOUNDING to have min dealy of 3ns between I1 port to O1
#note it can also be done using set_input_delay and set_output_delay as in #2. better to use #2


##################################################################################################
                      #5. analysis analysis
##################################################################################################
set_case_analysis 0/1/rising/falling [get_ports SE]  #THIS IS EXAMPLE FOR SFF


##################################################################################################
                      #6. operating conditions
##################################################################################################

set_operating_conditions -library <lib_name> -analysis_type <analysis_type> -max <max_condition> -min <min_condition> -max_library <max_lib> -min <min_lib>
#for more details go thorugh man command




set_timing_derate #why it is use learn it

set_units  -capacitance cap_unit  #for setting units  only give value unit will be taken from library (ns, fF, mv) whatever in lib file
set_units  -time time_unit
set_units  -voltage vol_unit
set_units  -resistance res_unit 
set_units  -current curr_unit 
set_units  -power power_unit    

#if not define it will take default from library



##################################################################################################
                      #7. wire load models 
##################################################################################################
set_wire_load_model -name <model_name>  #model name may be in library
set_wire_load_mode <mode_name>
wire_load_selection (grp1){
wire_load_from_area (0,100, "wireload_name1");
wire_load_from_area (100,400, "wireload_name2");
}


##################################################################################################
                      #8. Design Rule
##################################################################################################
set_max_capacitance
set_max_fanout
set_max_transition


##################################################################################################
                      #9. area, power
##################################################################################################

set_logic_zero <port_list>
set_logic_one <port_list>
set_logic_dc  <port_list>  #dont care that port


set_max_area 10 ##to set target area, be realistic to get min area , power and performance may deteriorate


set_voltage

set_max_dynamic_power power [unit]
set_max_leakage_power power [unit]

































