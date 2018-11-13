function  [Current_week_actual_load_data]= update_net_load(Schedule_index,Current_week_actual_load_data,ESS_estimated_schedule)

Current_week_actual_load_data(Schedule_index,2)=Current_week_actual_load_data(Schedule_index,1) + ESS_estimated_schedule{Schedule_index}(1);
%Running_peak_load=max(Current_week_actual_load_data(:,2));

end