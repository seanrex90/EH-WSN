% function [throughput,n_nodes] = EH_Random_Access(n_nodes,buff_cap,batt_cap,max_retx)

clear();
clc();

%%% INITIALISATION %%%

simlength = 10000;

batt_cap = 8;
buff_cap = 10 ;
% e_arr_v = [0 1] ;
% p_arr_v = [0 1] ;
max_retx = 4 ;
n_nodes = 2;

batt = randi([0 batt_cap],1,n_nodes);
buff = zeros(1,n_nodes);
backoff = zeros(1,n_nodes);
retx= zeros(1,n_nodes);

en_prob = 0.6;
pkt_prob = 0.8; 

p_burst = 5;
e_burst = 3; 

e_curr = zeros(1,n_nodes);
p_curr = zeros(1,n_nodes);

arr_count = zeros(1,n_nodes) ;
collision_flag = zeros(1,n_nodes) ;
tx_count = zeros(1,n_nodes) ;
drop_count = zeros(1,n_nodes);
drop_retx = zeros(1,n_nodes);
arr_count_t = 0;
drop_count_t = 0;
drop_retx_t = 0;
tx_count_t = 0;
tx_count_c = zeros(simlength,1);
throughput = zeros(simlength,1);

collision_count = 0;

time = 0 ;
timer = zeros(simlength,1);


while (time ~= simlength)
    
    e_arr = rand();    
    e_arr_p = rand(1,n_nodes);
    p_arr_p = rand(1,n_nodes);
    
    time = time + 1 ;  
    
    for i = 1:n_nodes % for all nodes transmitting simultaneousl
           
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
         arr_count_t = arr_count_t + 1;
         buff(i) = buff(i) + 1;  
            
           if(batt(i) > 0 )   % buff is not empty
			                 
               if(buff(i) > 0)  % battery available 
                                      
                   if(backoff(i) == 0)                                              
                         
                        collision_flag(i) = 1;         %Node 'i' can transmit                                                    
                        if(sum(collision_flag) == 1)   %if only one node can tranmit
                            tx_count(i) = tx_count(i) + 1 ; %Succesful tx
                            tx_count_t = tx_count_t + 1;
                            buff(i) = buff(i) - 1;
                            batt(i) = batt(i) - 1;
                        else
                            collision_count = collision_count + 1;
                            retx(i) = retx(i) + 1; 
                            if(retx(i) > max_retx)
                                retx(i) = 0;
                                drop_retx(i) = drop_retx(i) + 1; %dropped due to retx window 
                                drop_retx_t = drop_retx_t + 1;
                                buff(i) = buff(i) - 1 ;
                            end
                            backoff(i) = randi([0 (2^retx(i) - 1)]); %backoff recalculated
                            batt(i) = batt(i) - 1;                            
                        end
                        
                   else
                       collision_flag(i) = 0; %no nodes ready to tx
                       backoff(i) = backoff(i)-1; %decrease backoff
                             
                   end                                     
               end
                    
                    
             else
                    %energy exhausion/battery died
                    batt(i) = 0;
                    
                    if buff(i) >0
                        
                        if backoff(i) == 0 
                        
                        retx(i) = retx(i) + 1; %incr retx and recalc backoff
                        backoff(i) = randi([1 (2^retx(i) - 1)]) ;                     
                            if(retx(i) > max_retx) %pkt dropped due to max_retx
                                retx(i) = 0;
                                drop_retx(i) = drop_retx(i) + 1 ; 
                                drop_retx_t = drop_retx_t + 1;
                                buff(i) = buff(i) - 1 ; 
                            end
                        else
                            backoff(i) = backoff(i) - 1;
                        end
                    else
                        backoff(i) = backoff(i) - 1;
                         if backoff(i) < 0
                             backoff(i) = 0;
                         end
                    end
            end
           
        else
            %no packet arrived
           if(batt(i) > 0 )   % buff is not empty
			                 
               if(buff(i) > 0)  % battery available 
                                      
                   if(backoff(i) == 0)                                                
                         
                        collision_flag(i) = 1;                                                             
                        if(sum(collision_flag) == 1)
                            tx_count(i) = tx_count(i) + 1 ;
                            tx_count_t = tx_count_t + 1;
                            buff(i) = buff(i) - 1;
                            batt(i) = batt(i) - 1;
                        else
                            collision_count = collision_count + 1;
                            retx(i) = retx(i) + 1;
                            if(retx(i) > max_retx)
                                retx(i) = 0;
                                drop_retx(i) = drop_retx(i) + 1;
                                drop_retx_t = drop_retx_t + 1;
                                buff(i) = buff(i) - 1 ;
                            end
                            backoff(i) = randi([0 (2^retx(i) - 1)]); 
                            batt(i) = batt(i) - 1;
                        end
                                                
                   else
                       collision_flag(i) = 0;
                       backoff(i) = backoff(i)-1;                            
                   end
                                           
               end
                    
             else
                    %energy exhausion/battery died
                    batt(i) = 0;
                    
                    if buff(i) >0
                        
                        if backoff(i) == 0 
                        
                        retx(i) = retx(i) + 1; %incr retx and recalc backoff
                        backoff(i) = randi([1 (2^retx(i) - 1)]) ;                     
                            if(retx(i) > max_retx) %pkt dropped due to max_retx
                                retx(i) = 0;
                                drop_retx(i) = drop_retx(i) + 1 ;
                                drop_retx_t = drop_retx_t + 1;
                                buff(i) = buff(i) - 1 ; 
                            end
                        else
                            backoff(i) = backoff(i) - 1;
                        end
                    else
                         backoff(i) = backoff(i) - 1;
                         if backoff(i) < 0
                             backoff(i) = 0;
                         end
                    end
                    
           end
     end
            if(buff(i) > buff_cap)
                buff(i)=buff(i) - 1;
                drop_count(i) = drop_count(i) + 1;
                drop_count_t = drop_count_t +1;
            end
        
        % 2-state markov chain for energy arrival state        if (e_arr_p(i) > en_prob)
        if (e_curr(i) ==0)
            if (e_arr >= (1/e_burst))
                e_curr(i) = 1;
            else
                e_curr(i) = 0;
            end
        elseif(e_curr(i) == 1)
            if (e_arr >= (en_prob/(e_burst*(1-en_prob))))
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
    tx_count_c (time,1) = tx_count_t;
end
% end


