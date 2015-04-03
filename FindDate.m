function IND = FindDate(TIME,d1,d2)
% Returns indices of times between d1 and d2.
%
% No, it doesn't find you a date for Friday.
%
% SYNTAX:
%	IND = FindDate(TIME,d1,d2)
%
% INPUTS:
%	TIME	= Nx7 matrix - time_builder format dates
%				or
%			= Nx1 vector - dates in matlab serial format
%	d1		= 1x1 scalar - matlab serial date of sequence beginning
%	d2		= 1x1 scalar - matlab serial date of sequence end
%
% OUTPUTS:
%	IND		= 1xM vector - Index of TIME between d1 and d2

%%%%%%%%%%%%
%% CHECKS %%
%%%%%%%%%%%%
if size(TIME,2) == 7
	TIME = TIME(:,7);
end
if d1 > d2
	error('d1 must be the beggining time and d2 the ending time')
end

%%%%%%%%%%
%% CODE %%
%%%%%%%%%%
IND = find(TIME >= d1 & TIME <= d2);