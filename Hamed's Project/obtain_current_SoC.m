function  [battery_paramaters]=obtain_current_SoC(ESS_schedule,battery_paramaters,time_slot_duration)

%%In practice we obtain the current SoC from the system, however, here we
%%calcuate it based on the battery nominal data
current_SOC=battery_paramaters(6);
%%% charging
if ESS_schedule>0
    current_SOC=current_SOC+battery_paramaters(3)*time_slot_duration*ESS_schedule ;
else
    %%%discharging
    current_SOC=current_SOC+ (1/battery_paramaters(3))*time_slot_duration*ESS_schedule ;
    
end
battery_paramaters(6)=current_SOC;
end