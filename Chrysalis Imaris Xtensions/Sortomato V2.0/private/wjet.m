function wjetMap = wjet(varargin)
%   WJET Generate a wjet colormap
%
%   Syntax
%   ------ 
%   cMap = WJET(256);
%   cMap = WJET;
%   set(gcf, 'ColorMap', WJET)
%
%   Description
%   ------------
%   WJET(M) generates an mx3 WJET colormap, a variant of the Jet coloramp.
%   The colors begin with white, transition from light to dark blue,
%   through shades of cyan, green, yellow, and end with red. WJET, by
%   itself, is the same length as the current figure's colormap. If no
%   figure exists, MATLAB creates one.
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
    
    wjetMap = zeros([mapSize 3]);

    %% Create the wjet transition points.
    S1 = ceil(0.2*mapSize);
    S2 = ceil(0.4*mapSize);
    S3 = ceil(0.6*mapSize);
    S4 = ceil(0.8*mapSize);
    
    %% Create the red component.
    wjetMap(1:S1, 1) = linspace(1, 0, S1 - 0);
    wjetMap(S2:S3) = linspace(0, 1, S3 - S2 + 1);
    wjetMap(S3:end, 1) = 1;
    
    %% Create the green component.
    wjetMap(1:S1, 2) = linspace(1, 0, S1 - 0);
    wjetMap(S1:S2, 2) = linspace(0, 1, S2 - S1 + 1);
    wjetMap(S2:S3, 2) = 1;
    wjetMap(S3:end, 2) = linspace(1, 0, mapSize - S3 + 1);
    
    %% Create the blue component.
    wjetMap(1:S2, 3) = 1;
    wjetMap(S2:S4, 3) = linspace(1, 0, S4 - S2 + 1);
    
end

