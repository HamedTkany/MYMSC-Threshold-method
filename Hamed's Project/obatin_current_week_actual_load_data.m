
function [Current_week_actual_load_data] = obatin_current_week_actual_load_data(load_time_stamp,load_value,current_week_time_stamps)
data_length=length(current_week_time_stamps);

Current_week_actual_load_data=zeros(data_length,2);
%%% this is the actual original load of the building; the first columns is  without ess
%%% and the second column is the net load with ESS output

Week_start_date_time=current_week_time_stamps{1};
Week_end_timestamp=current_week_time_stamps{data_length};

temp1=Week_start_date_time(1:10);
temp2=Week_start_date_time(12:13);
temp3=Week_start_date_time(14:15);
temp4=Week_start_date_time(16:17);
Formated_string=[temp1,' ',temp2,':',temp3];


for i=32993:length(load_time_stamp)
    idx = strcmp([load_time_stamp{i}], Formated_string);
    
    ck=5;
    if isequal(idx,1),
        Current_time_actual_load=load_value(i);
        load_time_stamp(1:i)=[];
        load_value(1:i)=[];
        break
    end
end
Current_week_actual_load_data(1,1)=Current_time_actual_load;


temp1=Week_end_timestamp(1:10);
temp2=Week_end_timestamp(12:13);
temp3=Week_end_timestamp(14:15);
temp4=Week_end_timestamp(16:17);
Formated_string=[temp1,' ',temp2,':',temp3];

for i=2:length(load_time_stamp)
    idx = strcmp([load_time_stamp{i-1}], Formated_string);
    
    Current_week_actual_load_data(i,1)=load_value(i-1);
    
    
    
    ck=5;
    if isequal(idx,1),
        %        Current_time_actual_load=load_value(i);
        %         load_time_stamp(1:i-1)=[];
        %         load_value(1:i-1)=[];
        break
    end
    
end




end
