function  [count,forecast_mean]=average(Current_week_predictions,Current_week_forecast_time_stamppp,current_week_time_stamps)
    summ = zeros(length(current_week_time_stamps),1);
    count = zeros(length(current_week_time_stamps),1);
    for i = 1:length(current_week_time_stamps)
        t = datetime(current_week_time_stamps(i),'timezone','UTC','InputFormat','yyyy-MM-dd''T''HHmmss');
        summ(i) = 0;
        for j = i:-1:(i-94)
            if(j>0)
                if(Current_week_forecast_time_stamppp{j}(i-j+1) == t)
                    summ(i) = summ(i) + Current_week_predictions{j}(i-j+1);
                    count(i) = count(i) + 1;
                end
            end
        end
    end
    forecast_mean = summ ./ count;
end