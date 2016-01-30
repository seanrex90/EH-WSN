clear();
clc();

%%% INITIALISATION %%%

simlength = 10000;

batt_cap = 5;
buff_cap = 10 ;
e_arr_v = [0 1] ;
p_arr_v = [0 1] ;
max_retx = 4 ;

alpha = 0.4;
beta = 0.7;

e_burst = 2;
p_burst = 5; 

time = 0 ;

for n_nodes = 1 : 10

throughput = EH_Random_Access(n_nodes,buff_cap,batt_cap,max_retx);

end
