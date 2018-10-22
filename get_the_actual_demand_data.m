
function [load_time_stamp, load_value]=get_the_actual_demand_data()

filename = 'dee1.csv';
delimiter = ',';
startRow = 2;

formatSpec = '%{MM-dd-yy HH:mm}D%*s%[^\n\r]';
fileID = fopen(filename,'r');

dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter, 'HeaderLines' ,startRow-2);
%dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter, 'TextType', 'string', 'EmptyValue', NaN, 'HeaderLines' ,startRow-1, 'ReturnOnError', false, 'EndOfLine', '\r\n');
a = datestr(dataArray{1,1},'yyyy-mm-dd HH:MM');
load_time_stamp = cellstr(a);
fclose(fileID);


formatSpec = '%*s%f%[^\n\r]';
fileID = fopen(filename,'r');

dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter, 'HeaderLines' ,startRow-2);
%dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter, 'TextType', 'string', 'EmptyValue', NaN, 'HeaderLines' ,startRow-1, 'ReturnOnError', false, 'EndOfLine', '\r\n');


load_value = dataArray{:, 1};

fclose(fileID);


end


