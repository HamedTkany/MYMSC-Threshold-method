function [ opt_prmt ]=initialize_optimization_parameters()
time_slot_duration=(1/4);  %% time slot duration in hours
Final_SoC_surplus=0 ;  %%% this value would be p.u.
Running_peak_load= 0;
opt_prmt=[time_slot_duration;Final_SoC_surplus;Running_peak_load];
end