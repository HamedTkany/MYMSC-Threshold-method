
function [local_datetime_vector]= obtain_local_time_date_vector(UTC_date_string)
temp1=UTC_date_string(1:10);
temp2=UTC_date_string(12:13);
temp3=UTC_date_string(14:15);
temp4=UTC_date_string(16:17);
Formated_date_string=[temp1, ' ', temp2, ':', temp3, ':', temp4];

temp5=datetime(Formated_date_string,'TimeZone','UTC');
temp5.TimeZone='America/Los_Angeles';

%         temp5=datenum(Formated_date_string);
%         temp5= temp5- (8/24);
%

local_datetime_vector=temp5;


end
