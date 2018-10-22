function [battery_paramaters]=obtain_the_battery_system_parameters()

inverter_kw= 60;
capacity_kwh= 120;
efficiency_factor=sqrt(0.85) ; %% the round trip efficiency is 0.85
SOC_full=1*capacity_kwh;   % percentage of the full SOC
SOC_empty=0*capacity_kwh;
current_SOC=1*capacity_kwh;


battery_paramaters=[inverter_kw;capacity_kwh;efficiency_factor;SOC_full;SOC_empty; current_SOC ];
end