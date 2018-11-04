function [Net_load_w_ESS_kw]=Plot7()
filename = 'Dterministic_Output_data_Week31.csv';
delimiter = ',';
startRow = 2;
formatSpec = '%q%f64%f64%f64%[^\n\r]';
fileID = fopen(filename,'r');
dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter, 'HeaderLines' ,startRow-1);
Net_load_w_ESS_kw = dataArray{:,3};
fclose(fileID);
area(Net_load_w_ESS_kw );
end