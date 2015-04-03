function varout = TimeAverage(t,varin,OPT)
% Takes a vector and averages over the indicated time interval.
%
% SYNTAX
%   varout = TimeAverage(t,varin,OPT)
%
% INPUTS
%   t      = Nx7 time_builder formated matrix of the same length as varin.
%   varin  = Nx1 vector to be averaged.
%   OPT    = String indicating averaging interval (ignores case):
%               'hour'
%               'day'
%				'10day'
%				'month'
%               'year'
%
% OUTPUTS
%   varout = Vector of same length of varin with averages done over the
%            indicated interval
% NOTE: THIS FUNCTION NEEDS TO BE UPDATED TO DEAL WITH THE NEW FUNCTIONALITY OF TimeID.m
varout = NaN(size(varin));

if strcmpi(OPT,'hour')
	
	dt = mode(diff(t(:,7))); % steps per day
	hr = 1./24; % days per hour
	step = round(hr/dt); % steps per hour
	if step < 1
		error('Cannot average a time step greater than an hour to an hour')
	end
	
	hour = TimeID(t,'HOUR');
	for n =1:length(hour)
		varout(hour(n,1):hour(n,2)) = nanmean(varin(hour(n,1):hour(n,2)));
	end
	
elseif strcmpi(OPT,'day')
	dt = mode(diff(t(:,7))); % steps per day
	day = 1; % days
	step = round(day/dt); % steps per day
	if step < 1
		error('Cannot average a time step greater than day to a day')
	end
	
	day = TimeID(t,'DAY');
	for n =1:length(day)
		varout(day(n,1):day(n,2)) = nanmean(varin(day(n,1):day(n,2)));
	end
	
elseif strcmpi(OPT,'10day')
	dt = mode(diff(t(:,7))); % steps per day
	day = 1; % days
	step = round(day/dt); % steps per day
	if step < 10
		error('Cannot average a time step greater than 10 days to 10 days')
	end
	
	day10 = TimeID(t,'10DAY');
	for n =1:length(day10)
		varout(day10(n,1):day10(n,2)) = nanmean(varin(day10(n,1):day10(n,2)));
	end
	
elseif strcmpi(OPT,'month')
	MONTH = TimeID(t,'MONTH');
	for n =1:length(MONTH)
		varout(MONTH(n,1):MONTH(n,2)) = nanmean(varin(MONTH(n,1):MONTH(n,2)));
	end
	
elseif strcmp(OPT,'year')
	yrs = [t(diff(t(:,1)) == 1,1),max(t(:,1))];
	for n =1:length(yrs)
		ind = find(t(:,1) == yrs(n));
		varout(ind(1):ind(end)) = nanmean(varin(ind(1):ind(end)));
	end
end

