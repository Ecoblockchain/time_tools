function ind = TimeID(t,OPT)
% Function returns the indices of the time period in question. Useful for daily calculations.
% 
% SYNTAX
%	ind = TimeID(t,OPT)
%
% INPUTS
%	t    = Lx7 matrix of dates in time_builder format
%	OPT  = String specifying time interval.
%			'DAY' - Returns indices for beginning and end of each day
%			'HOUR' - Returns indices for beginning and end of each hour
%			'10DAY'
%			'MONTH'
%							OR
%	OPT	= 1x1 scalar, dt of desired time interval in matlab serial format
%
% OUTPUT
%	ind  = ?x2 matrix. 1st column is beginning interval. 2nd column is end of interval.
%	       The length of the returned matrix depends on the number of intervals of the 
%	       desired length contained within t.

% NOTE: The way that this function works, you end up with 0000-0000 hours
% when using the day sub-period (similar wrapping of the indices for other
% sub-periods). This is a consequence of how FindDate.m works. I might want
% to fix this someday.

%% Checks %%
if size(t,2) ~= 7
	error('Time matrix must be in time_builder format')
end

%% Code %%
if ~ischar(OPT)
	dt = Get_dt(t);
	if OPT < dt
		error('Variable length is less than the time step of input data')
	end
	
	% Steps of OPT days, matlab serial date format
	TIND = [t(1,7):OPT:t(end,7)];
	% If time does not evenly go into OPT days, force ends to match
	if TIND(end,2) ~= t(end,7)
		TIND = [TIND,t(end,7)];
	end
	% Find indices of OPT day periods
	ind = NaN(length(TIND)-1,2);
	for n = 1:length(TIND)-1
		j = FindDate(t,TIND(n),TIND(n+1));
		ind(n,:) = [min(j),max(j)];
	end
	
elseif strcmpi(OPT,'DAY') && ischar(OPT)

	DAY = [0;find(diff(t(:,3)) ~= 0);length(t)];
	ind = [DAY(1:end-1)+1,DAY(2:end)];

elseif strcmpi(OPT,'10DAY') && ischar(OPT)
	
	% Steps of 10 days, matlab serial date format
	DAY10 = [t(1,7):10:t(end,7)];
	% If time does not evenly go into 10 days, force ends to match
	if DAY10(end,2) ~= t(end,7)
		DAY10 = [DAY10,t(end,7)];
	end
	% Find indices of 10 day periods
	ind = NaN(length(DAY10)-1,2);
	for n = 1:length(DAY10)-1
		j = FindDate(t,DAY10(n),DAY10(n+1));
		ind(n,:) = [min(j),max(j)];
	end
	
elseif strcmpi(OPT,'MONTH') && ischar(OPT)

	MONTH = [0;find(diff(t(:,2)) ~= 0);length(t)];
	ind = [MONTH(1:end-1)+1,MONTH(2:end)];

elseif strcmpi(OPT,'HOUR') && ischar(OPT)

	HOUR = [0;find(diff(t(:,4)) ~= 0);length(t)];
	ind = [HOUR(1:end-1)+1,HOUR(2:end)];

end
