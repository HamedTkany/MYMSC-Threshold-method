function [Time_stamp, Original_load_kw , forecast_mean ]=Plot5()
filename = 'Dterministic_Output_data_32.csv';
delimiter = ',';
startRow = 2;
formatSpec = '%q%f64%f64%f64%[^\n\r]';
fileID = fopen(filename,'r');
dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter, 'HeaderLines' ,startRow-1);
% a = datestr(dataArray{1,1},'yyyy-mm-ddTHHMMSS');
Time_stamp = cellstr(dataArray{1,1});
forecast_mean= dataArray{:,2};
Original_load_kw = dataArray{:,4};
fclose(fileID);
X = datenum( Time_stamp,'yyyy-mm-ddTHHMMSS');
plot( X, Original_load_kw );
xlabel('31 October to 7 November')
ylabel('Kw')
datetick('x','yyyy-mm-ddTHHMMSS');
hold on
plot( X, forecast_mean , 'r' );
legend('original load','Mean Forecast');
end