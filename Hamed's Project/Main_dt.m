
[load_time_stamp, load_value]=get_the_actual_demand_data();
[Weekly_time_stamps]=Partition_the_prediction_data();


[battery_paramaters]=obtain_the_battery_system_parameters();

Assigned_week_numbers = [41,42,43,44];
for Week_number=Assigned_week_numbers
    [current_week_time_stamps]=Weekly_time_stamps{Week_number};

    [Current_week_actual_load_data,Current_week_predictions,Current_week_forecast_time_stamppp]=obtain_current_week_data_dt(Week_number,Weekly_time_stamps,load_time_stamp,load_value);

 

    ESS_estimated_schedule=cell(length(current_week_time_stamps),1);
    Estimated_SoC=cell(length(current_week_time_stamps),1);


    [ opt_prmt ]=initialize_optimization_parameters();

% % %     aaa = zeros(length(current_week_time_stamps),1);
% % %     Current_week_predictions_96=arrange(Current_week_predictions);
    for Schedule_index=1:length(current_week_time_stamps)

        load_prediction_kw= Current_week_predictions{Schedule_index};
% % %         aaa(Schedule_index) = mean(load_prediction_kw);
        [opt_prmt]=update_optimization_paramters(opt_prmt,load_prediction_kw,battery_paramaters, Current_week_actual_load_data);

        ESS_estimated_schedule{Schedule_index}=zeros(95,1);
        [ESS_estimated_schedule{Schedule_index}, Estimated_SoC{Schedule_index} ]=obtain_ESS_schedule(load_prediction_kw, battery_paramaters, opt_prmt);

        [battery_paramaters]=obtain_current_SoC(ESS_estimated_schedule{Schedule_index}(1),battery_paramaters,opt_prmt(1));


        [Current_week_actual_load_data]= update_net_load(Schedule_index,Current_week_actual_load_data,ESS_estimated_schedule);

        Schedule_index

    end

    ESS_week_schedule=zeros(length(Current_week_actual_load_data),1);
    ESS_week_soc=zeros(length(Current_week_actual_load_data),1);
    for schedule_num=1:length(Current_week_actual_load_data)
        ESS_week_schedule(schedule_num)=ESS_estimated_schedule{schedule_num}(1);
        ESS_week_soc(schedule_num)=Estimated_SoC{schedule_num}(1); 
    end


    temp1=num2str(Week_number);
    save (['week_outputs_',temp1, '.mat']);     
end