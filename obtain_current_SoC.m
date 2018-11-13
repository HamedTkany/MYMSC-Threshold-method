function  [battery_paramaters,ESS_real_time_schedule]=obtain_current_SoC(battery_paramaters,time_slot_duration,CT,DCT,Current_week_actual_load_data_reshape)

%%In practice we obtain the current SoC from the system, however, here we
%%calcuate it based on the battery nominal data
current_SOC=battery_paramaters(6);
%%% charging
if Current_week_actual_load_data_reshape < CT 
    ESS_schedule= CT - Current_week_actual_load_data_reshape ;
    current_SOC=current_SOC+battery_paramaters(3)*time_slot_duration*ESS_schedule ;

elseif Current_week_actual_load_data_reshape > DCT
    %%%% Hossein:: This does not seem right, what about the times that the
    %%%% battery is left idle?!!
    %%%discharging
    ESS_schedule = Current_week_actual_load_data_reshape - DCT ;
    current_SOC=current_SOC+ (1/battery_paramaters(3))*time_slot_duration*ESS_schedule ;
else
    ESS_schedule=0;
    current_SOC=current_SOC;
end
battery_paramaters(6)=current_SOC;
ESS_real_time_schedule=ESS_schedule ;

%%%  Hossein This last line should 
end