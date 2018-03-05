function pushregiongraphcallback(hObject, eventData, figSortomatoGraph, figSortomato, varargin)
    % PUSHREGIONGRAPHCALLBACK Graph objects in the selected region
    %   Detailed explanation goes here
    %
    %   ©2010-2013, P. Beemiller. Licensed under a Creative Commmons Attribution
    %   license. Please see: http://creativecommons.org/licenses/by/3.0/
    %
    
    %% Get the selected region's tag.
    popupRegions = findobj(figSortomatoGraph, 'Tag', 'popupRegions');
    popupString = get(popupRegions, 'String');
    
    if strcmp(popupString, ' ')
        return
    end % if
    
    if nargin == 5
        rgnGraphString = varargin{1};
        
    else
        if iscell(popupString)
            popupValue = get(popupRegions, 'Value');
            rgnGraphString = popupString{popupValue};

        else
            rgnGraphString = popupString;

        end % if
        
    end % if
    
    %% Determine the region type, get the position and convert to vertices.
    axesGraph = findobj(figSortomatoGraph, 'Tag', 'axesGraph');
    regionStruct = getappdata(axesGraph, 'regionStruct');
    
    switch rgnGraphString(1:4)

        case 'Elli'
            % Get the position of the ellipse to use for the graph.
            ellipseToGraph = strcmp({regionStruct.Ellipse.Name}, rgnGraphString);
            rgnPosition = regionStruct.Ellipse(ellipseToGraph).getPosition;

            % The position vector is a bounding box. Convert the dims to radii
            % and the center.
            r1 = rgnPosition(3)/2;
            r2 = rgnPosition(4)/2;
            eCenter = [rgnPosition(1) + r1, rgnPosition(2) + r2];

            % Generate an ellipse in polar coordinates using the radii.
            theta = transpose(linspace(0, 2*pi, 100));
            r = r1*r2./(sqrt((r2*cos(theta)).^2 + (r1*sin(theta)).^2));

            [ellX, ellY] = pol2cart(theta, r);
            rgnVertices = [ellX + eCenter(1), ellY + eCenter(2)];

        case 'Poly'
            % Get the position of the polygon to use for the graph.
            polyToGraph = strcmp({regionStruct.Poly.Name}, rgnGraphString);

            % The getPosition method returns vertices for polygons.
            rgnVertices = regionStruct.Poly(polyToGraph).getPosition;

        case 'Rect'
            % Get the position of the rectangle to sort.
            rectToGraph = strcmp({regionStruct.Rect.Name}, rgnGraphString);
            rgnPosition = regionStruct.Rect(rectToGraph).getPosition;

            % Convert the x-y-width-height into the 4 corners of the rectangle.
            % The order is important to generate a rectangle, rather than a 'z'.
            rgnVertices = zeros(4, 2);
            rgnVertices(1, :) = rgnPosition(1:2); % Lower-left
            rgnVertices(2, :) = [rgnPosition(1) + rgnPosition(3), rgnPosition(2)];
            rgnVertices(3, :) = [rgnPosition(1) + rgnPosition(3), ...
                rgnPosition(2) + rgnPosition(4)];
            rgnVertices(4, :) = [rgnPosition(1), rgnPosition(2) + rgnPosition(4)];

        otherwise % It's a freehand region.
            % Get the position of the freehand region to use for the graph.
            freehandToGraph = strcmp({regionStruct.Freehand.Name}, rgnGraphString);

            % The getPosition method returns vertices for freehand regions.
            rgnVertices = regionStruct.Freehand(freehandToGraph).getPosition;

    end % switch

    %% Get the plotted value indices that fall within the region to graph.
    axesGraph = findobj(figSortomatoGraph, 'Tag', 'axesGraph');
    xData = getappdata(axesGraph, 'xData');
    yData = getappdata(axesGraph, 'yData');
    
    % Using a single output, inpolygon includes points on the region.
    inPlotIdxs = inpolygon(xData, yData, ...
        rgnVertices(:, 1), rgnVertices(:, 2));

    %% Check for a request to graph the objects outside the region.
    % If the user wants to graph the objects outside the region, we take
    % the points outside the region. We can reuse the code for the sorting
    % and graphing, so the two toolbar buttons share this callback. We
    % check for which button was pressed to determine whether to keep the
    % in points or switch to the out points.
    if strcmp(get(hObject, 'Tag'), 'pushRegionOutsideGraph') || ...
            strcmp(get(hObject, 'Tag'), 'menuRegionOutsideGraph')
        inPlotIdxs = ~inPlotIdxs;
    end % if

    %% Find the index in the stat struct for the y axes selection.
    popupY = findobj(figSortomatoGraph, 'Tag', 'popupY');
    statIdx = get(popupY, 'Value');

    %% Get the spot/track IDs that correspond to the graphed points.
    % These need to get converted to double for use as inputs to the Surfaces
    % Get methods.
    statStruct = getappdata(figSortomatoGraph, 'statStruct');
    inIDs = double(statStruct(statIdx).Ids(inPlotIdxs));
    
    %% Mask the stat structure fields on the matching indices.
    maskedStruct = struct(statStruct);
    idxMask = ismember(double(maskedStruct(1).Ids), inIDs);
    
    for p = 1:size(maskedStruct, 2)
        maskedStruct(p).Ids = maskedStruct(p).Ids(idxMask);
        maskedStruct(p).Values = maskedStruct(p).Values(idxMask);
    end % for p

    %% Call the graph function with the filtered stat data.
    sortomatograph(hObject, [], maskedStruct, figSortomato, rgnGraphString)
end % pushregiongraphcallback