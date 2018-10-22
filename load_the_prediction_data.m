
function  [UTC_time_stamppp, local_time_stamps, load_prediction_kw]= load_the_prediction_data(Current_time_stamp)
filename=['fcst_for_opt_pb/dee1_',Current_time_stamp,'.csv'];


delimiter = ',';
startRow = 2;

formatSpec = '%s%*s%[^\n\r]';
fileID = fopen(filename,'r');
if isequal(fileID,-1),
    error('File could not Open');
end

dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter, 'HeaderLines' ,startRow-1);

temp= dataArray{:, 1};
local_time_stamps=cell(length(temp),1);
for count=1:length(temp)
    temp2= temp{count, 1};
    local_time_stamps{count} =temp2(1:19);
    UTC_time_stamppp = datetime(temp,'TimeZone','America/Los_Angeles','InputFormat','yyyy-MM-dd HH:mm:ssZ');
end
UTC_time_stamppp.TimeZone = 'UTC';
fclose(fileID);



%formatSpec = '%*s%f%[^\n\r]';
formatSpec = '%*s%f%[^\n\r]';
fileID = fopen(filename,'r');

%dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter, 'HeaderLines' ,startRow-1);

dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter, 'HeaderLines' ,startRow-1);

load_prediction_kw = dataArray{:, 1};

fclose(fileID);

end
