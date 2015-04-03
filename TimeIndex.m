function TIND = TimeIndex(TIME,INT)
% Determines indices in the time vector, t, for the given interval, INT.
% Starts index from the first time stamp.
%
% SYNTAX:
%	TIND = TimeIndex(TIME,INT);
%
% INPUT:
%	TIME	= Nx7 matrix - time_builder format dates
%	INT		= 1x1 scalar - time step in days
%
% OUTPUT:
%	TIND	= Mx2 vector - indices where:
%			(M,1) is the beginning of the interval
%			(M,2) is the end of the interval
%
% DEPENDENCIES:
%

%%%%%%%%%%%%
%% CHECKS %%
%%%%%%%%%%%%
if numel(INT) ~= 1
	error('INT must be a 1x1 scalar')
end
if size(TIME,2) ~=7 && size(TIME,2) ~= 1
	error('Time variable, t, must either be a time_builder format matrix or a vector of serial dates')
end
if size(TIME,2) == 7
	TIME = TIME(:,7);
end

%%%%%%%%%%
%% CODE %%
%%%%%%%%%%
% Determine INT to the nearest minute
dt_quant = 1/(24*60);						% Minute time step 
dt_num = round(INT./dt_quant);				% Number of minutes in time step
INT = dt_num.*dt_quant;						% Time step in integer minutes

% Determine the number of time steps within the requested interval
len = length(TIME);							% Number of elements in the time record
dt = Get_dt(TIME);							% Time step in minutes
numsteps = INT/dt;							% Number of steps w/in interval
numints = round(len/numsteps);				% Number of intervals w/in time matrix, skip any fractions
if mod(numsteps,1) >= 1*10^-6				% The time step is not in minutes
	error('Time step does not divide into the requested interval in integer minutes')
elseif mod(numsteps,1) <= 1*10^-6			% The time step is in minutes
	numsteps = round(numsteps);				% Remove any round-off error
end

% Assign indices
TIND = NaN(numints,2);						% Pre-allocate index variable
for n = 0:numints-1							% loop over the # of intervals
	TIND(n+1,:) = [(n.*numsteps)+1,(n.*numsteps)+numsteps];% Beginning and end of the interval
end
TIND(end,2) = len;							% Force the last index to be the end of the vector
