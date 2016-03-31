function CDST = Correct_t_DaylightSavings_CDWR(DST,FTC)
% Function corrects TIME for daylight savings so that it is a constant
% offset from UTC year-round. To do this it needs to cut out time steps and
% add a time step.
%
% SYNTAX:
%
%
% INPUTS:
%
%
% OUTPUTS:
%
%
% NOTES:
%	This code has been untested for time steps with a length other than an
%	hour.

%%%%%%%%%%%%%%%%%%%%%%%
%% CHECKS/FORMATTING %%
%%%%%%%%%%%%%%%%%%%%%%%
if ~isfield(DST,'t') || size(DST.t,2) ~= 7
	error('Must have time field named t in time builder format')
end
TIME = DST.t;
if iscell(FTC)
	for n = 1:length(FTC)
		if ~isfield(DST,FTC{n})
			error('Specified field to correct was not found in the input structure')
		end
	end
else
	error('Fields to correct must be a cell array')
end

%%%%%%%%%%
%% CODE %%
%%%%%%%%%%
% Identify periods w/ DST
DLS = false(length(TIME),1);
for n = 1:length(TIME)
	DLS(n) = is_DLS(TIME(n,:));
end

DLS = ~DLS;

% Get time step
dt = Get_dt(TIME);								% Time step in serial format

% Remove additional hour
NODLS_TIME = TIME(:,7);							% Matlab serial format
NODLS_TIME(DLS) = TIME(DLS,7)+dt;				% Remove serial hour

% Add steps for those lost
loststep = find(diff(NODLS_TIME) > (dt + .001));
if ~isempty(loststep)
	for n = 1:length(FTC);
		CDST.(FTC{n}) = CorrectFields_Lost(DST,FTC{n},loststep);
	end
	NODLS_TIME = CorrectFields_Lost_t(NODLS_TIME,loststep,dt);
elseif isempty(loststep)
	CDST = DST;
end
	
% Removed repeated time stamps
gainstep = find(diff(NODLS_TIME) < (dt - .001));
if ~isempty(gainstep)
	for n = 1:length(FTC)
		CDST.(FTC{n}) = CorrectFields_Gain(CDST,FTC{n},gainstep);
	end
	NODLS_TIME = CorrectFields_Gain_t(NODLS_TIME,gainstep);
end

% Build new time matrix
CDST.t =  time_builder(NODLS_TIME);
end

%%%%%%%%%%%%%%%%%%%
%% SUB-FUNCTIONS %%
%%%%%%%%%%%%%%%%%%%
function NODLS = CorrectFields_Lost(DST,FTC,loststep)
% Repeat previous step to fill lost step
	NODLS = zeros(length(DST.(FTC))+length(loststep),1);
	NODLS(loststep + (0:length(loststep)-1)') = 1;
	NODLS(~NODLS) = DST.(FTC);
	NODLS(loststep + (0:length(loststep)-1)') = DST.(FTC)(loststep);
end

function NODLS = CorrectFields_Lost_t(TIME,loststep,dt)
% Fill in missing time step
	% It is the proceeding time step from the difference indexing that 
	% needs to be adjusted
	loststep = loststep + 1;
	NODLS = zeros(length(TIME)+length(loststep),1);
	NODLS(loststep + (0:length(loststep)-1)') = NaN;
	NODLS(~isnan(NODLS)) = TIME;
	if loststep(1) ~= 1
		NODLS(find(isnan(NODLS)==1)) = NODLS(find(isnan(NODLS)==1)-1) + dt;
	end
	if loststep(1) == 1
		NODLS(1) = NODLS(2) - dt;
	end
end


function NODLS = CorrectFields_Gain(DST,FTC,gainstep)
% Remove repeated step
NODLS = DST.(FTC);
NODLS(gainstep,:) = [];
end

function TIME = CorrectFields_Gain_t(TIME,gainstep)
% Remove repeated step
TIME(gainstep,:) = [];
end