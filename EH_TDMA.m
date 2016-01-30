% function [throughput,users] = EH_Access_TDMA(n_nodes,buff_cap,batt_cap,max_retx,backoff)

clear();
clc();

%%% INITIALISATION %%%

simlength = 10000;

batt_cap = 8;
buff_cap = 10 ;
% e_arr_v = [0 1] ;
% p_arr_v = [0 1] ;
max_retx = 0 ;

n_nodes = 2;

batt = randi([0 batt_cap],1,n_nodes);
buff = randi([0 buff_cap],1,n_nodes);
retx= zeros(1,n_nodes);

en_prob = 0.6;
pkt_prob = 0.8; 

p_burst = 5;
e_burst = 3; 

e_curr = zeros(1,n_nodes);
p_curr = zeros(1,n_nodes);

alpha = 0.4;
curr_state = zeros(1,n_nodes);
arr_count = zeros(1,n_nodes) ;
tx_count_t = 0;
tx_count = zeros(1,n_nodes) ;
drop_count = zeros(1,n_nodes);
drop_retx = zeros(1,n_nodes);

time = 0 ;
timer = zeros(simlength,1);
tx_count_v = zeros(simlength,1);

time_slot = zeros(simlength,2);



while time ~= simlength
 
    e_arr_p = rand(1,n_nodes);
    p_arr_p = rand(1,n_nodes);
    
    time = time + 1;
   
    
 for i = 1:n_nodes
     
    slot = mod(time,n_nodes);
    if slot == 0
        slot = n_nodes;
    end 

     time_slot(time , 1) = slot ;
     time_slot(time , 2) = time ;
     
     % modelling packet arrival with burstiness 
        if (p_curr(i) ==0)
            if (p_arr_p >= (1/p_burst))
                p_curr(i) = 1;
            else
                p_curr(i) = 0;
            end
        elseif(p_curr(i) == 1)
            if (p_arr_p >= (pkt_prob/(p_burst*(1-pkt_prob))))
               p_curr(i) = 0;
            else
                p_curr(i) = 1;
            end
        end
     
     if(p_curr(i) == 1) %packet arrived 
         
         arr_count(i) = arr_count(i) + 1;
         buff(i) = buff(i) + 1;    
         
         if(time_slot(time,1) == i) %choose which node's timer slot it is
               
             if(batt(i)>0)
                 
                 if(buff(i)>0)
                    tx_count(i) = tx_count(i) + 1 ;
                    tx_count_t = tx_count_t + 1;
                    retx(i) = 0 ;
                    buff(i) = buff(i) -1;
                    batt(i) = batt(i) -1;
                    
                 end
                 
             elseif(batt(i)>batt_cap)
                % if battery is full 
                 batt(i) = batt_cap;
                 
             else  %  battery exhausted
                 if(buff(i)>0)
                     retx(i) = retx(i) + 1;
                     if(retx(i) > max_retx) 
                         retx(i) = 0;
                         buff(i) = buff(i) - 1;
                         drop_retx(i) = drop_retx(i) + 1;                        
                     end
                 end
             end
         end
             
             
      else %no packet arrived
         

         if(time_slot(time,1) == i) %choose which node's timer slot it is
               
             if(batt(i)>0)
                 
                 if(buff(i)>0)
                    tx_count(i) = tx_count(i) + 1 ;
                    tx_count_t = tx_count_t + 1;                  
                    retx(i) = 0 ;
                    buff(i) = buff(i) -1;
                    batt(i) = batt(i) -1;
                    
                 end
                 
             elseif(batt(i)>batt_cap)
                % if battery is full 
                 batt(i) = batt_cap;
                 
             else  %  battery exhausted
                 if(buff(i)>0)
                     retx(i) = retx(i) + 1;
                     if(retx(i) > max_retx) 
                         retx(i) = 0;
                         buff(i) = buff(i) - 1;
                         drop_retx(i) = drop_retx(i) + 1;                        
                     end
                 end
             end
         end                  
           
     end
     
        if(buff(i) > buff_cap)
                buff(i)=buff_cap;
                drop_count(i) = drop_count(i) + 1;
         end         
     
     % 2-state markov chain for energy arrival state        if (e_arr_p(i) > en_prob)
        if (e_curr(i) ==0)
            if (e_arr_p(i) >= (1/e_burst))
                e_curr(i) = 1;
            else
                e_curr(i) = 0;
            end
        elseif(e_curr(i) == 1)
            if (e_arr_p(i) >= (en_prob/(e_burst*(1-en_prob))))
               e_curr(i) = 0;
            else
                e_curr(i) = 1;
            end
        end
        if(e_curr(i) == 1)
            if(batt(i) < batt_cap)
                   batt(i) = batt(i) + 1;
            end            
        end
        
 end
    timer(time,1) = time;
    tx_count_v (time,1) = tx_count_t;
end
% end


