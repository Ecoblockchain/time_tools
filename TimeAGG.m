function [out out_t] = TimeAGG(t,dat,dt_agg,REF)
% This function aggregates fine resolution data to a coarser resolution.
% Input data must a time step that divides into a day evenly.
%
% SYNTAX:
%	out = TimeAGG(t,dat,dt_agg,REF)
%
% INPUTS:
%	t		= Nx7 time_builder formatted matrix of dates.
%	dat		= Nx1 vector of input data
%	dt_agg	= 1x1 scalar of time step for aggregated data in hours
%
% OUTPUTS:
%	out		= mx1 (m < N) vector of output data aggregated to the indicated step size
%	out_t	= mx7 matrix of dates in time_builder format
%
% DEPENDENCIES:
%	time_builder.m
%	Get_dt.m
%	FindDate.m

%%%%%%%%%%%%
%% CHECKS %%
%%%%%%%%%%%%
if size(t,2) ~= 7
	error('Time matrix expected to be in time_builder format (Nx7)')
end
if numel(t(:,7)) ~= numel(dat)
	error('Time and data vectors must be the same length')
end
if max(diff(t(:,7))) - min(diff(t(:,7))) > .0001
	error('Time must have a constant step size')
end

dt_dat = Get_dt(t)*24;
if  dt_agg < dt_dat
	error('Time step for aggregated data must be greater than the time step of input data')
end

out_t = time_builder(t(1,7),t(end,7),dt_agg);
if strcmp(REF,'BEG')					% Obs. avg. referenced to beginning of time step
	dt_s = dt_agg/24;					% Time step in serial format
	% Move time window to be in the middle of averaging period
	st = out_t(:,7)+dt_s./2;
elseif strcmp(REF,'END')				% Obs. avg. referenced to the end of time step
	dt_s = dt_agg/24;					% Time step in serial format
	% Move time window to be in the middle of averaging period
	st = out_t(:,7)-dt_s./2;
elseif strcmp(REF,'MID')				% Already referenced to the middle of the interval
	% Do nothing
	dt_s = dt_agg/24;					% Time step in serial format
	st = out_t(:,7);
else
	error('Unrecognized REF option')
end

%%%%%%%%%%%%%%%
%% AGGREGATE %%
%%%%%%%%%%%%%%%
% Initialize variables
out = NaN(length(out_t),1);

for n = 1:length(out_t)
	% Data at times around time step - referencing time stamp adjusted
	% above.
	temp = FindDate(t,st(n)-dt_s./2,st(n)+dt_s./2);
	if length(temp) > round(dt_agg./(2*dt_dat))	% More than 50% of the time step is available
		out(n) = nanmean(dat(temp));			% Average to the coarser time step
	end
end
