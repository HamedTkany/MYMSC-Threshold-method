function [Time_stamp, Original_load_kw, Net_load_w_ESS_kw, ESS_injection_kw]=Plot3()
filename = 'Dterministic_Output_data_44.csv';
delimiter = ',';
startRow = 2;
formatSpec = '%q%f64%f64%f64%[^\n\r]';
fileID = fopen(filename,'r');
dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter, 'HeaderLines' ,startRow-1);
Time_stamp = cellstr(dataArray{1,1});
Original_load_kw = dataArray{:,2};
Net_load_w_ESS_kw = dataArray{:,3};
ESS_injection_kw = dataArray{:,4};
fclose(fileID);
X = datenum( Time_stamp,'yyyy-mm-ddTHHMMSS');
plot( X, Original_load_kw );
xlabel('8 to 16 January')
ylabel('Kw')
datetick('x','yyyy-mm-ddTHHMMSS');
hold on
plot( X, Net_load_w_ESS_kw, 'r' );
hold on
plot( X, ESS_injection_kw, 'g' );
legend('Original load','Net Load','ESS injection')
end