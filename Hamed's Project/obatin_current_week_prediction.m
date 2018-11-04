
function [Current_week_forecast_time_stamppp,Current_week_predictions]= obatin_current_week_prediction(current_week_time_stamps)
Current_week_predictions=cell(length(current_week_time_stamps),1);
Current_week_forecast_time_stamppp=cell(length(current_week_time_stamps),1);
for i=1:length(current_week_time_stamps)
    
    Current_time_stamp=current_week_time_stamps{i};
    [UTC_time_stamppp,~, load_prediction_kw]=load_the_prediction_data(Current_time_stamp);
    Current_week_predictions{i}=load_prediction_kw;
    Current_week_forecast_time_stamppp{i}=UTC_time_stamppp;
    
end

end
