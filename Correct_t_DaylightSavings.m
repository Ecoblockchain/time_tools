function CDST = Correct_t_DaylightSavings(DST,FTC)
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

% Get time step
dt = Get_dt(TIME);								% Time step in serial format

% Remove additional hour
NODLS_TIME = TIME(:,7);							% Matlab serial format
NODLS_TIME(DLS) = TIME(DLS,7)-1./24;			% Remove serial hour

% Add steps for those lost
loststep = find(diff(NODLS_TIME) > dt + .001);
if ~isempty(loststep)
	for n = 1:length(FTC);
		CDST.(FTC{n}) = CorrectFields_Lost(DST,FTC{n},loststep);
	end
elseif isempty(loststep)
	CDST = DST;
end
	
% Removed repeated time stamps
gainstep = find(diff(NODLS_TIME) < dt - .001);
if ~isempty(gainstep)
	for n = 1:length(FTC)
		CDST.(FTC{n}) = CorrectFields_Gain(CDST,FTC{n},gainstep);
	end
end

% Deal with time
if ~isempty(loststep)
	NODLS_TIME = CorrectFields_Lost_t(NODLS_TIME,loststep,dt);
end
CDST.t = NODLS_TIME;
if ~isempty(gainstep)
	NODLS_TIME = CorrectFields_Gain(CDST,'t',gainstep);
end
% Build new time matrix
CDST.t =  time_builder(NODLS_TIME);
end

%%%%%%%%%%%%%%%%%%%
%% SUB-FUNCTIONS %%
%%%%%%%%%%%%%%%%%%%
function NODLS = CorrectFields_Lost(DST,FTC,loststep)
% Repeat previous step to fill lost step
% for n = 1:length(loststep)
	NODLS = zeros(length(DST.(FTC))+length(loststep),1);
	NODLS(loststep + (0:length(loststep)-1)') = 1;
	NODLS(~NODLS) = DST.(FTC);
	NODLS(loststep + (0:length(loststep)-1)') = DST.(FTC)(loststep);
% end
end

function NODLS = CorrectFields_Lost_t(TIME,loststep,dt)
% Fill in missing time step
for n = 1:length(loststep)
	NODLS = zeros(length(TIME)+length(loststep),1);
	NODLS(loststep + (0:length(loststep)-1)') = 1;
	NODLS(~NODLS) = TIME;
	NODLS(loststep + (0:length(loststep)-1)') = NaN;
	if loststep(1) ~= 1
		NODLS(loststep + (0:length(loststep)-1)') = NODLS(find(isnan(NODLS))-1)+dt;
	end
end
end

function NODLS = CorrectFields_Gain(DST,FTC,gainstep)
% Remove previous step to fill repeated step
NODLS = DST.(FTC);
NODLS(gainstep,:) = [];
end



