function Daylight_Savings = is_DLS(DATE)
%Function takes a date as a string in 'mm/dd/yyyy' format and outputs a
%logical, true if the date is during daylight savings time for that year. See
%definition of daylight savings time in the USA
%
% HISTORY:
%	Modified by K. Lapo to use time_builder format for a speed boost (use the
%	boost to get through!) and to be accurate pre-2007.
%
% SYNTAX:
%
%
% INPUTS:
%
%
% OUTPUTS:
%
if size(DATE,2) ~= 7
	error('DATE must be in time_builder format')
end

if DATE(1) >= 2007
	Daylight_Savings = DST_EPA(DATE);
elseif DATE(1) > 1986 && DATE(1) < 2007
	Daylight_Savings = DST_PRE(DATE);
end

end

function Daylight_Savings = DST_EPA(DATE)
% Daylight Savings for post 2007 after the passage of the Energy Policy Act
% of 2005.
Month = DATE(2);
if (Month > 3) && (Month < 11) %If the month is between April and October, true
    Daylight_Savings = true;
elseif (Month < 3) || (Month == 12) %If month is January, February, or December, false
    Daylight_Savings = false;
elseif Month == 3 %If month is March
    Sunday_Vect = [];
    for j = 1:31 %Loop through all 31 days of March, finding the Sundays
		March_Date = datenum(DATE(1),3,j,0,0,0);
        DOW = weekday(March_Date); 
        if DOW == 1 %DOW is 1 if the day is a Sunday
            Sunday_Vect = [Sunday_Vect j];
        end
    end
    DS_Day = Sunday_Vect(2); %Take the 2nd Sunday in March
    My_Day = DATE(3);
    if My_Day >= DS_Day %If on or after 2nd Sunday, true
        Daylight_Savings = true; 
    else
        Daylight_Savings = false;
    end
elseif Month == 11 %If month is November
    Sunday_Vect = [];
    for j = 1:30 %Loop through all 30 days of November, finding the Sundays
		Nov_Date = datenum(DATE(1),11,j,0,0,0);
        DOW = weekday(Nov_Date); 
        if DOW == 1 %DOW is 1 if the day is a Sunday
            Sunday_Vect = [Sunday_Vect j];
        end
	end
    DS_Day = Sunday_Vect(1); %Take the 1st Sunday of the month
    My_Day = DATE(3);
    if My_Day < DS_Day %If it is before the 1st Sunday, true
        Daylight_Savings = true;
    else
        Daylight_Savings = false;
    end
end
end

function Daylight_Savings = DST_PRE(DATE)
% Daylight Savings for pre 2007 when the start date was the first Sunday in
% April and the end date was the last Sunday in October.
Month = DATE(2);
if (Month > 4) && (Month < 10) %If the month is between April and October, true
    Daylight_Savings = true;
elseif (Month < 4) || (Month == 11) || (Month == 12) %If month is January, February, November, or December, false
    Daylight_Savings = false;
elseif Month == 4 %If month is April
    Sunday_Vect = [];
    for j = 1:30 %Loop through all 31 days of April, finding the Sundays
		April_Date = datenum(DATE(1),4,j,0,0,0);
        DOW = weekday(April_Date); 
        if DOW == 1 %DOW is 1 if the day is a Sunday
            Sunday_Vect = [Sunday_Vect j];
        end
    end
    DS_Day = Sunday_Vect(1); %Take the 1st Sunday in April
    My_Day = DATE(3);
    if My_Day >= DS_Day %If on or after 1st Sunday, true
        Daylight_Savings = true; 
    else
        Daylight_Savings = false;
    end
elseif Month == 10 %If month is October
    Sunday_Vect = [];
    for j = 1:31 %Loop through all 31 days of October, finding the Sundays
		Oct_Date = datenum(DATE(1),10,j,0,0,0);
        DOW = weekday(Oct_Date); 
        if DOW == 1 %DOW is 1 if the day is a Sunday
            Sunday_Vect = [Sunday_Vect j];
        end
	end
    DS_Day = Sunday_Vect(end); %Take the last Sunday of the month
    My_Day = DATE(3);
    if My_Day < DS_Day %If it is before the last Sunday, true
        Daylight_Savings = true;
    else
        Daylight_Savings = false;
    end
end
end