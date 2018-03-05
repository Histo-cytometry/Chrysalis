function jetbwMap = jetbw(varargin)
%   JETBW Generate a jetbw colormap
%
%   Syntax
%   ------ 
%   cMap = JETBW(256);
%   cMap = JETBW;
%   set(gcf, 'ColorMap', JETBW)
%
%   Description 
%   ------------ 
%   JETBW(M) generates an mx3 JETBW colormap, a variant of the Jet
%   coloramp. The colors begin with black, then dark blue, and range
%   through blue, green and red, ending with white. JETBW, by itself, is
%   the same length as the current figure's colormap. If no figure exists,
%   MATLAB creates one.
%
%   See also HSV, HOT, PINK, FLAG, COLORMAP, RGBPLOT.
%   
%   ©2013, P. Beemiller. Licensed under a Creative Commmons Attribution
%   license. Please see:
%   http://creativecommons.org/licenses/by/3.0/
    
    %% Get the map size.
    if nargin < 1
        mapSize = size(get(gcf, 'colormap'), 1);
        
    else
        mapSize = varargin{1};
        
    end % if
        
    jetbwMap = zeros([mapSize, 3]);

    %% Create the jetbw transition points.
    S1 = ceil(0.2*mapSize);
    S2 = ceil(0.4*mapSize);
    S3 = ceil(0.6*mapSize);
    S4 = ceil(0.8*mapSize);
    
    %% Create an indexed red range.
    jetbwMap(S2:S3) = linspace(0, 1, S3 - S2 + 1);
    jetbwMap(S3:end, 1) = 1;
    
    %% Create an indexed green range.
    jetbwMap(S1:S2, 2) = linspace(0, 1, S2 - S1 + 1);
    jetbwMap(S2:S3, 2) = 1;
    jetbwMap(S3:S4, 2) = linspace(1, 0, S4 - S3 + 1);
    jetbwMap(S4:end, 2) = linspace(0, 1, mapSize - S4 + 1);
    
    %% Create an indexed blue range.
    jetbwMap(1:S1, 3) = linspace(0, 1, S1 - 0);
    jetbwMap(S1:S2, 3) = 1;
    jetbwMap(S2:S3, 3) = linspace(1, 0, S3 - S2 + 1);
    jetbwMap(S4:end, 3) = linspace(0, 1, mapSize - S4 + 1);
end % jetbw

