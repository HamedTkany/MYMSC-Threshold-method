Time_stamp=cell(1,1);
Original_load_kw=[];
Net_load_w_ESS_kw=[];
ESS_injection_kw=[];
ESS_net_injected_kwh=[];

count=1;
all_forecast_mean = 0;
counttt = 0;
Number_of_found_date_for_avarage = 0;
for week_number=41:44
    
    temp1=num2str(week_number);
    
    
    load (['week_outputs_',temp1, '.mat']);
    
    [counttt,forecast_mean] = average(Current_week_predictions, Current_week_forecast_time_stamppp, current_week_time_stamps);
    all_forecast_mean = [all_forecast_mean;forecast_mean];
    Number_of_found_date_for_avarage = [Number_of_found_date_for_avarage;counttt];
    Original_load_kw=[Original_load_kw;Current_week_actual_load_data(:,1)];
    Net_load_w_ESS_kw=[Net_load_w_ESS_kw;Current_week_actual_load_data(:,2)];
 
    
    temp1=max(0,-ESS_week_schedule);
    if week_number>41,
        temp2=ESS_net_injected_kwh(end)+tril(ones(length(Current_week_actual_load_data),length(Current_week_actual_load_data)))*temp1;
    else
        temp2=tril(ones(length(Current_week_actual_load_data),length(Current_week_actual_load_data)))*temp1;        
    end
    ESS_week_net_injected=temp2;
    
    ESS_net_injected_kwh=[ESS_net_injected_kwh;ESS_week_net_injected];
    ESS_injection_kw=[ESS_injection_kw;ESS_week_schedule];
    
    for i=1:length(Current_week_actual_load_data)
        Time_stamp(count,1)=current_week_time_stamps(i,1);
        count=count+1;
    end
    
% % %     forecast_mean = [forecast_mean;aaa];
end
all_forecast_mean = all_forecast_mean(2:2689);
Number_of_found_date_for_avarage = Number_of_found_date_for_avarage(2:2689);
% % % plot(forecast_mean)
% % % hold on
% % % plot(Original_load_kw,'color','red');
Output_data=table(Time_stamp,all_forecast_mean,Number_of_found_date_for_avarage,Original_load_kw,Net_load_w_ESS_kw,ESS_injection_kw,ESS_net_injected_kwh);
writetable(Output_data,'Dterministic_Output_data.csv','Delimiter',',','QuoteStrings',true)