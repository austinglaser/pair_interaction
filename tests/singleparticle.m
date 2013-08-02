% Calculate the diffusion of a single particle, using binning techniques.
% - Split track into 'bins' and analyze coefficient of each bin, starting
%   from the first point in that bin and thus compensating for overall
%   drift.
% - Average position across bin, and use that as a single datapoint to
%   calculate diffusion.

% Read in data and configuration
%   Config file specifies:
%       - Framerate and conversion ('scale')
%       - Analysis type
%       - File configuration
%       - List of input folders

prefs = read_config('./configuration.ini');

% Split data into bins

% Analyze

% Present results