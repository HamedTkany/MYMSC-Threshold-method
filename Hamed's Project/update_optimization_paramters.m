function [opt_prmt]=update_optimization_paramters(opt_prmt,load_prediction_kw,battery_paramaters, Current_week_actual_load_data)
Threshold=30;
Current_SoC=battery_paramaters(6);
Final_SoC_surplus=opt_prmt(2);

if (length(load_prediction_kw)<95)
    Final_SoC_surplus= battery_paramaters (2) -Current_SoC;
end


opt_prmt(2)=Final_SoC_surplus;
opt_prmt(3)=max(Current_week_actual_load_data(:,2) ) -Threshold;
end