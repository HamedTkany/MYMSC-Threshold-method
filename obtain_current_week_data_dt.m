function  [actual_load_data,Current_week_predictions,Current_week_forecast_time_stamppp]=obtain_current_week_data_dt(Week_number,Weekly_time_stamps,load_time_stamp,load_value)

    [current_week_time_stamps]=Weekly_time_stamps{Week_number};
    data_length=length(current_week_time_stamps);

    [actual_load_data]=obatin_current_week_actual_load_data(load_time_stamp,load_value,current_week_time_stamps);


    [Current_week_forecast_time_stamppp,Current_week_predictions]=obatin_current_week_prediction(current_week_time_stamps );




    %   Week_start_date_time=current_week_time_stamps{1};
    Week_end_timestamp=current_week_time_stamps{data_length};
    for Schedule_index=1:data_length
        Current_time_stamp=current_week_time_stamps{Schedule_index};
        [Current_week_forecast_time_stamppp{Schedule_index},Current_week_predictions{Schedule_index}]=Adjust_prediction_data(Current_time_stamp,Week_end_timestamp);

    end

end