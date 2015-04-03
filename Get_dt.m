function dt = Get_dt(TIME)
% Determines the serial date format time step to the nearest minute.
% Assumes a constant time step.
%
% SYNTAX:
%	dt = Get_dt(t);
%
% INPUT:
%	t	= Nx7 matrix - time_builder format dates
%
% OUTPUT:
%	dt	= 1x1 scalar - time step in serial date format to the nearest minute
%
% DEPENDENCIES:
%

%%%%%%%%%%%%
%% CHECKS %%
%%%%%%%%%%%%
if size(TIME,2) ~=7 && size(TIME,2) ~= 1
	error('Time variable, t, must either be a time_builder format matrix or a vector of serial dates')
end
if size(TIME,2) == 7
	TIME = TIME(:,7);
end

%%%%%%%%%%
%% CODE %%
%%%%%%%%%%

% Determine time step
len = length(TIME);							% Length of the time matrix
[dt,f] = mode(diff(TIME));					% Time step in serial format and frequency of each time step
norm_f = f./len;							% % of data w/ given time step
if sum(norm_f(2:end) > .1)					% More than 10% of the points have a different time step
	error('An inconsistent time step was detected')
else
	dt = dt(1);								% Ignore all other detected time steps
end

% Round to nearest minute
dt_quant = 1/(24*60);						% Minute time step 
dt_num = round(dt./dt_quant);				% Number of minutes in time step
dt = dt_num.*dt_quant;						% Time step in integer minutes
