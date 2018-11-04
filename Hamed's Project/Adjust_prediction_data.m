
function [UTC_time_stamppp,load_prediction_kw]=Adjust_prediction_data(Current_time_stamp,Week_end_timestamp)
%%% remove the prediction values not belong to current week. this is
%%% the would be the case for the predictions last day of week


Week_end_datevec=obtain_local_time_date_vector(Week_end_timestamp);
Current_time_vector=obtain_local_time_date_vector(Current_time_stamp);

[UTC_time_stamppp,local_time_stamps, load_prediction_kw]=load_the_prediction_data(Current_time_stamp);


ck2=1;
if ( datenum(Week_end_datevec)-datenum(Current_time_vector)<(1))
    %%% So for the 6 days of the  week all the predction data belongs to
    %%% the same week, and we use all the vector size, but for the last day
    %%% we need to truncate the predictions and accordingly the decision
    [UTC_time_stamppp,load_prediction_kw]= truncate_the_next_week_prediction_data(UTC_time_stamppp,local_time_stamps, load_prediction_kw,Week_end_datevec);
    ck3=1;
    
end




    function[UTC_time_stamppp,load_prediction_kw]= truncate_the_next_week_prediction_data(UTC_time_stamppp,local_time_stamps, load_prediction_kw,Week_end_datevec)
        
        
        %%% horizon
        
        temp=local_time_stamps(end);
        temp2=datetime(temp,'TimeZone','America/Los_Angeles');
        
        
        while ~isequal(Week_end_datevec.Day, temp2.Day )
            ck=4;
            UTC_time_stamppp(end)=[];
            local_time_stamps(end)=[];
            load_prediction_kw(end)=[];
            temp=local_time_stamps(end);
            temp2=datetime(temp,'TimeZone','America/Los_Angeles');
            
        end
        
        
    end
end
