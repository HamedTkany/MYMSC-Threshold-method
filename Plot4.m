function  [local_time_stamps, load_prediction_kw]= Plot4()
filename=['fcst_for_opt_pb/dee1_','.csv'];
delimiter = ',';
startRow = 2;
formatSpec = '%q%f64%f64%f64%[^\n\r]';
fileID = fopen(filename,'r');
dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter, 'HeaderLines' ,startRow-1);
temp= dataArray{:, 1};
local_time_stamps=cell(length(temp),1);
for count=1:length(temp)
    temp2= temp{count, 1};
    local_time_stamps{count} =temp2(1:19);
end
fclose(fileID);
formatSpec = '%*s%f%[^\n\r]';
fileID = fopen(filename,'r');
dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter, 'HeaderLines' ,startRow-1);
load_prediction_kw = dataArray{:, 1};
fclose(fileID);
plot ( local_time_stamps , load_prediction_kw ) ;
datetick('x','yyyy-mm-ddTHHMMSS');
end
