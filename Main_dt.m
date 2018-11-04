
clear
clc
dbstop if error
[load_time_stamp, load_value]=get_the_actual_demand_data();
[Weekly_time_stamps]=Partition_the_prediction_data();


[battery_paramaters]=obtain_the_battery_system_parameters();

Assigned_week_numbers = [41,42,43,44];
for Week_number=Assigned_week_numbers
    [current_week_time_stamps]=Weekly_time_stamps{Week_number};

    [Current_week_actual_load_data,Current_week_predictions,Current_week_forecast_time_stamppp]=obtain_current_week_data_dt(Week_number,Weekly_time_stamps,load_time_stamp,load_value);

    Current_week_actual_load_data_reshape=arrayfun(@(x){repmat(x,95,1)},Current_week_actual_load_data(:,1));

    ESS_estimated_schedule=cell(length(current_week_time_stamps),1);
    ESS_real_time_schedule=cell(length(current_week_time_stamps),1);
    Estimated_SoC=cell(length(current_week_time_stamps),1);
    CT=cell(length(current_week_time_stamps),1);
    DCT=cell(length(current_week_time_stamps),1); 
    K=cell(length(current_week_time_stamps),1);
    H=cell(length(current_week_time_stamps),1);
    
    optimazation_parameters=cell(length(current_week_time_stamps),1); %in order to check opimization inputs in each iteration
    Battery_Parameters = cell(length(current_week_time_stamps),1); %in order to check opimization inputs in each iteration
    Prediction_of_Load = cell(length(current_week_time_stamps),1); %in order to check opimization inputs in each iteration
    Ainequality = cell(length(current_week_time_stamps),1); %in order to check opimization inputs in each iteration
    binequality = cell(length(current_week_time_stamps),1); %in order to check opimization inputs in each iteration
    Aequality = cell(length(current_week_time_stamps),1); %in order to check opimization inputs in each iteration
    bequality = cell(length(current_week_time_stamps),1); %in order to check opimization inputs in each iteration
    Lowerbound = cell(length(current_week_time_stamps),1); %in order to check opimization inputs in each iteration
    Upperbound = cell(length(current_week_time_stamps),1); %in order to check opimization inputs in each iteration
    Vartype = cell(length(current_week_time_stamps),1); %in order to check opimization inputs in each iteration
    
    [ opt_prmt ]=initialize_optimization_parameters();

% % %     aaa = zeros(length(current_week_time_stamps),1);
% % %     Current_week_predictions_96=arrange(Current_week_predictions);
    for Schedule_index=1:length(current_week_time_stamps)
    Schedule_index

        load_prediction_kw= Current_week_predictions{Schedule_index};
% % %         aaa(Schedule_index) = mean(load_prediction_kw);
        [opt_prmt]=update_optimization_paramters(opt_prmt,load_prediction_kw,battery_paramaters, Current_week_actual_load_data);

        ESS_estimated_schedule{Schedule_index}=zeros(95,1);
        CT{Schedule_index}=zeros(95,1);
        DCT{Schedule_index}=zeros(95,1);
        
        optimazation_parameters{Schedule_index} = { opt_prmt(1) ; opt_prmt(2) ; opt_prmt(3) } ; %in order to check opimization inputs in each iteration
        Battery_Parameters{Schedule_index} = { battery_paramaters(1) ; battery_paramaters(2) ; battery_paramaters(3);battery_paramaters(4) ;battery_paramaters(5);battery_paramaters(6) } ; %in order to check opimization inputs in each iteration
        Prediction_of_Load{Schedule_index} = load_prediction_kw ;%in order to check opimization inputs in each iteration
       
        [ESS_estimated_schedule{Schedule_index}, Estimated_SoC{Schedule_index},CT{Schedule_index},DCT{Schedule_index},K{Schedule_index},H{Schedule_index},Answer_all,Aineq,bineq,Aeq,beq,lowerbound,upperbound,vartype]=obtain_ESS_schedule(load_prediction_kw, battery_paramaters, opt_prmt);

        [battery_paramaters,ESS_real_time_schedule{Schedule_index}]=obtain_current_SoC(battery_paramaters,opt_prmt(1),CT{Schedule_index}(1),DCT{Schedule_index}(1),Current_week_actual_load_data_reshape{Schedule_index}(1));


        [Current_week_actual_load_data]= update_net_load(Schedule_index,Current_week_actual_load_data,ESS_real_time_schedule);

       
        Ainequality = Aineq ;%in order to check opimization inputs in each iteration
        binequality = bineq ;%in order to check opimization inputs in each iteration
        Aequality = Aeq ;%in order to check opimization inputs in each iteration
        bequality = bineq ;%in order to check opimization inputs in each iteration
        Lowerbound = lowerbound ;%in order to check opimization inputs in each iteration
        Upperbound = upperbound ;%in order to check opimization inputs in each iteration
        Vartype = vartype ;%in order to check opimization inputs in each iteration
        
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