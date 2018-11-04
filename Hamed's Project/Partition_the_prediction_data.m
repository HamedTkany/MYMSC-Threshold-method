function [Assigned_time_stamps]=Partition_the_prediction_data()
%%% we Partition the data to separate each weeks of data.
%%% we want to parttion the data so that the prediction data (or at least
%%% the date-time stamp of each week are separated
%%% if we are given the date of the first week we can obtain the dates of
%%% all the succesive weeks (well untill the data files run out)
%%% we can do it basically with two loops


Assigned_time_stamps=cell(52,1);

data_start_date_time='2016-03-14T000000'; % We start from the starting of the first Sunday in the data
Week_num=0;
Week_start_date=data_start_date_time;
[Start_date]=obtain_local_time_date_vector(Week_start_date);
[End_date]=obtain_next_week_start_date(Start_date);
State=true;
while State
    Week_num=Week_num+1;
    
    [Weekly_data_time_stamps]= get_the_week_timestamps (Start_date,End_date);
    
    Start_date=End_date;
    [End_date]=obtain_next_week_start_date(Start_date);
    [State]=Is_end_date_within_data(End_date);
    Assigned_time_stamps{Week_num}=Weekly_data_time_stamps;
    
end



Assigned_time_stamps(Week_num+1:end)=[];

end


%%


function[Weekly_data_time_stamps]= get_the_week_timestamps(Start_date,End_date)
%%% The duration of the assigned period  is
%%% 1 week,i.e equal to 96*7 instances

Estimated_period_length=96*7;

Weekly_data_time_stamps=cell(Estimated_period_length,1);
Current_datetime=Start_date;
% % % % % % % % % Current_date=floor(datenum(Start_date));
% % % % % % % % % %%% we are only interested in the day
% % % % % % % % % End_date=datenum(End_date);
% % % % % % % % % %%%  These values are local time
% % % % % % % % % 
% % % % % % % % % counter=0;
% % % % % % % % % while (Current_date-1 < End_date)%%%%%%menhaye yek ezafeh shod
% % % % % % % % %     counter=counter+1;
% % % % % % % % %     [Current_datetime_string]=convert_datevector_to_UTC_string(Current_datetime);
% % % % % % % % %     Weekly_data_time_stamps{counter}=Current_datetime_string;
% % % % % % % % %     %temp=datenum(Current_datetime)+((1/4)/24);
% % % % % % % % %     Current_datetime=Current_datetime +((1/4)/24);
% % % % % % % % %     
% % % % % % % % %     %   Current_datetime=datevec(temp);
% % % % % % % % %     Current_date=datenum(Current_datetime);
% % % % % % % % % end
counter = 0;
while(Current_datetime < End_date)
    counter = counter + 1;
    [Current_datetime_string]=convert_datevector_to_UTC_string(Current_datetime);
    Weekly_data_time_stamps{counter}=Current_datetime_string;
    Current_datetime.Minute = Current_datetime.Minute + 15;
end
Weekly_data_time_stamps(counter+1:end)=[];
end


function [UTC_datetime_string]=convert_datevector_to_UTC_string(local_date_vector)

%temp=datenum(local_date_vector)+(8/24);
% % % % % % % % % % local_date_vector.TimeZone='UTC';
local_date_vector.Hour = local_date_vector.Hour + 8;
temp2=datestr(local_date_vector,'yyyymmddTHHMMSS');
temp3=temp2(9:15);
temp4=temp2(1:4);
temp5=temp2(5:6);
temp6=temp2(7:8);

UTC_datetime_string=[temp4,'-',temp5,'-',temp6,temp3];

end



function[End_date]=obtain_next_week_start_date(Start_date)
%         date_vector=Start_date;
%         temp=datenum(date_vector)+7;
%         End_date=datevec(temp);
End_date = Start_date + 7;
% if isequal(End_date.Hour,1),
%     End_date=End_date-(1/24);
% end
% if isequal(End_date.Hour,23),
%     End_date=End_date+(1/24);
% end

end

function [State]=Is_end_date_within_data(date_vector)

[UTC_datetime_string]=convert_datevector_to_UTC_string(date_vector);

File_name=['fcst_for_opt_pb/dee1_',UTC_datetime_string,'.csv'];
File__id=fopen(File_name);

if isequal(File__id,-1),
    State=false;
else
    State=true;
    fclose(File__id);
    
end
end


function [local_datetime_vector]=obtain_local_time_date_vector(UTC_date_string)
temp1=UTC_date_string(1:10);
temp2=UTC_date_string(12:13);
temp3=UTC_date_string(14:15);
temp4=UTC_date_string(16:17);
Formated_date_string=[temp1, ' ', temp2, ':', temp3, ':', temp4];

temp5=datetime(Formated_date_string,'TimeZone','UTC');
% % % % % % % % % % temp5.TimeZone='America/Los_Angeles';
temp5.Hour = temp5.Hour - 8;

%         temp5=datenum(Formated_date_string);
%         temp5= temp5- (8/24);
%

local_datetime_vector=temp5;


end

