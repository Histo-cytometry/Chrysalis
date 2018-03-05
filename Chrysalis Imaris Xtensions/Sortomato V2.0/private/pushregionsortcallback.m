function pushregionsortcallback(hObject, eventData, figSortomatoGraph, figSortomato, varargin)
    % PUSHREGIONSORTCALLBACK Sort objects in the selected region
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
        rgnSortString = varargin{1};
        
    else
        if iscell(popupString)
            popupValue = get(popupRegions, 'Value');
            rgnSortString = popupString{popupValue};

        else
            rgnSortString = popupString;

        end % if
        
    end % if
    
    %% Determine the region type, get the position and convert to vertices.
    axesGraph = findobj(figSortomatoGraph, 'Tag', 'axesGraph');
    regionStruct = getappdata(axesGraph, 'regionStruct');
    
    switch rgnSortString(1:4)

        case 'Elli'
            % Get the position of the ellipse to use for the graph.
            ellipseToSort = strcmp({regionStruct.Ellipse.Name}, rgnSortString);
            rgnPosition = regionStruct.Ellipse(ellipseToSort).getPosition;

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
            polyToSort = strcmp({regionStruct.Poly.Name}, rgnSortString);

            % The getPosition method returns vertices for polygons.
            rgnVertices = regionStruct.Poly(polyToSort).getPosition;

        case 'Rect'
            % Get the position of the rectangle to sort.
            rectToSort = strcmp({regionStruct.Rect.Name}, rgnSortString);
            rgnPosition = regionStruct.Rect(rectToSort).getPosition;

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
            freehandToSort = strcmp({regionStruct.Freehand.Name}, rgnSortString);

            % The getPosition method returns vertices for freehand regions.
            rgnVertices = regionStruct.Freehand(freehandToSort).getPosition;

    end % switch

    %% Get the plotted value indices that fall within the region to graph.
    axesGraph = findobj(figSortomatoGraph, 'Tag', 'axesGraph');
    xData = getappdata(axesGraph, 'xData');
    yData = getappdata(axesGraph, 'yData');
    
    % Using a single output, inpolygon includes points on the region.
    inPlotIdxs = inpolygon(xData, yData, ...
        rgnVertices(:, 1), rgnVertices(:, 2));

    %% Check for a request to sort the objects outside the region.
    % If the user wants to graph the objects outside the region, we take
    % the points outside the region. We can reuse the code for the sorting
    % and graphing, so the two toolbar buttons share this callback. We
    % check for which button was pressed to determine whether to keep the
    % in points or switch to the out points.
    if strcmp(get(hObject, 'Tag'), 'pushRegionOutsideSort') || ...
            strcmp(get(hObject, 'Tag'), 'menuRegionOutsideSort')
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

    %% Get the Imaris objects and create a factory.
    xImarisApp = getappdata(figSortomatoGraph, 'xImarisApp');
    xObject = getappdata(figSortomatoGraph, 'xObject');
    
    xScene = xImarisApp.GetSurpassScene;
    xFactory = xImarisApp.GetFactory;
    
    %% Update the status bar.
    hStatus = statusbar(figSortomatoGraph, ['Sorting ' rgnSortString]);
    
    %% Determine whether we are sorting whole tracks or singlets.
    graphType = regexp(get(figSortomatoGraph, 'Name'), ...
        '(Singlets)|(Tracks)', 'Match', 'Once');
    
    %% Sort the selected data based on whether it is tracked or not.
    switch graphType

        case 'Tracks'
        % The inIDs calculated above represent parent (track) IDs. We first
        % build a list of objects that belong to the parents, then sort.
            %% Sort the objects with track edges into a tracked Surpass object.
            if xFactory.IsSpots(xObject) % Spot sorting
                %% Get the Spots.
                xObject = xFactory.ToSpots(xObject);

                % Get the selected Spots data, track IDs and edges.
                xSpotsData = xObject.Get;

                % Get the selected Spots track IDs and edges.
                xSpotsIDs = xObject.GetTrackIds;
                xSpotsEdges = xObject.GetTrackEdges;

                %% Sort the Spots.
                inTracks = ismember(xSpotsIDs, inIDs);

                % Get the edges.
                inEdges = xSpotsEdges(inTracks, :);

                % Get the spot indices from the edge connections.
                inIdxs = unique(inEdges);

                %% Create a new spot index list.
                % The inSpots variable will get mapped to new spots.
                newSpots = transpose(0:length(inIdxs) - 1);

                % Map the entries in the selection edge array to new spots.
                [linA, inSpotsIdx] = ismember(inEdges(:), inIdxs);

                % Preallocate an array and remap the edges.
                newEdges = zeros(size(inEdges));
                newEdges(:) = newSpots(inSpotsIdx(:));

                %% Create a Spots instance for the sorted Spots.
                sortSpots = xFactory.CreateSpots;

                % Name the Spots.
                if strcmp(get(hObject, 'Tag'), 'pushRegionSort') || ...
                        strcmp(get(hObject, 'Tag'), 'menuRegionSort')
                    sortName = [char(xObject.GetName) ' - ' ...
                        'Inside ' rgnSortString];

                else
                    sortName = [char(xObject.GetName) ' - ' ...
                        'Outside ' rgnSortString];

                end % if

                % Set the name of the Imaris object.
                sortSpots.SetName(sortName)

                %% Set the Spots.
                % Need to add 1 to the Imaris indices to index the
                % proper rows.
                sortSpots.Set(xSpotsData.mPositionsXYZ(inIdxs + 1, :), ...
                    xSpotsData.mIndicesT(inIdxs + 1, :), xSpotsData.mRadii(inIdxs + 1, :))

                % Set the track edges.
                sortSpots.SetTrackEdges(newEdges);

                % Place the sorted Spots into the Imaris scene.
                xScene.AddChild(sortSpots, -1)

            else % Surface sorting
                %% Get the Surfaces.
                xObject = xFactory.ToSurfaces(xObject);

                % Get the selected Surfaces track IDs and edges.
                xSurfacesIDs = xObject.GetTrackIds;
                xSurfacesEdges = xObject.GetTrackEdges;

                %% Sort the Surfaces.
                inTracks = ismember(xSurfacesIDs, inIDs);

                % Get the edges.
                inEdges = xSurfacesEdges(inTracks, :);

                % Get the surface indices from the edges connections.
                inIdxs = unique(inEdges);

                %% Create a new surface index list.
                % The inSurfaces variable will get mapped to new spots.
                newSurfaces = transpose(0:length(inIdxs) - 1);

                % Map the entries in the selection edge array to new spots.
                [linA, inSurfacesIdx] = ismember(inEdges(:), inIdxs);

                % Preallocate an array and remap the edges.
                newEdges = zeros(size(inEdges));
                newEdges(:) = newSurfaces(inSurfacesIdx(:));

                %% Create a Surfaces instance for the sorted Surfaces.
                sortSurfaces = iFactory.CreateSurfaces;

                % Name the Surfaces.
                if strcmp(get(hObject, 'Tag'), 'pushRegionSort') || ...
                        strcmp(get(hObject, 'Tag'), 'menuRegionSort')
                    sortName = [char(xObject.GetName) ' - ' ...
                        'Inside ' rgnSortString];

                else % We are sorting the objects outside the region.
                    sortName = [char(xObject.GetName) ' - ' ...
                        'Outside ' rgnSortString];

                end % if

                % Set the name of the Imaris object.
                sortSurfaces.SetName(sortName)

                %% Set the Surfaces.
                % Update the status bar.
                hStatus.ProgressBar.setMaximum(length(inIdxs))
                hStatus.ProgressBar.setVisible(true)

                % Add the indicated surfaces to the sorted Surfaces.
                for s = 1:length(inIdxs)
                    % Get the surface data for the current index.
                    sNormals = xObject.GetNormals(inIdxs(s));
                    sTime = xObject.GetTimeIndex(inIdxs(s));
                    sTriangles = xObject.GetTriangles(inIdxs(s));
                    sVertices = xObject.GetVertices(inIdxs(s));

                    % Add the surface to the sorted Surface using the data.
                    sortSurfaces.AddSurface(sVertices, sTriangles, sNormals, sTime)

                    % Update the progress bar.
                    hStatus.ProgressBar.setValue(s)
                end % s

                % Set the track edges.
                sortSurfaces.SetTrackEdges(newEdges);

                % Place the sorted Surfaces into the Imaris scene.
                xScene.AddChild(sortSurfaces, -1)

            end % if

        case 'Singlets'
            %% Sort the individual objects into a new, untracked Surpass object.
            if xFactory.IsSpots(xObject) % Spot sorting
                %% Get the spots.
                xObject = xFactory.ToSpots(xObject);

                % Get the selected Spots data.
                xSpotsData = xObject.Get;

                % Get the spot indices to sort. The spot indices to
                % sort are the IDs found by inpoly. The variable rename
                % is for variable name consistency with track sorting.
                inIdxs = inIDs;

                %% Create a Spots instance for the sorted Spots.
                sortSpots = xFactory.CreateSpots;

                % Name the Spots.
                if strcmp(get(hObject, 'Tag'), 'pushRegionSort') || ...
                        strcmp(get(hObject, 'Tag'), 'menuRegionSort')
                    sortName = [char(xObject.GetName) ' - ' ...
                        'Inside ' rgnSortString];

                else
                    sortName = [char(xObject.GetName) ' - ' ...
                        'Outside ' rgnSortString];

                end % if

                % Set the name of the Imaris object.
                sortSpots.SetName(sortName)

                %% Set the sorted Spots.
                % Need to add 1 to the Imaris indices to index the
                % proper rows.
                sortSpots.Set(xSpotsData.mPositionsXYZ(inIdxs + 1, :), ...
                    xSpotsData.mIndicesT(inIdxs + 1, :), xSpotsData.mRadii(inIdxs + 1, :))

                % Place the sorted Spots into the Imaris scene.
                xScene.AddChild(sortSpots, -1)

            else % Surface sorting
                %% Get the Surfaces.
                xObject = xFactory.ToSurfaces(xObject);

                % Get the surfaces indices to sort. The spots indices to
                % sort are the IDs found by inpoly. The variable rename
                % is for variable name consistency with track sorting.
                inIdxs = inIDs-double(min(statStruct(statIdx).Ids));

                %% Create a Surfaces instance for the sorted Surfaces.
                sortSurfaces = xFactory.CreateSurfaces;

                % Name the Surfaces.
                if strcmp(get(hObject, 'Tag'), 'pushRegionSort') || ...
                        strcmp(get(hObject, 'Tag'), 'menuRegionSort')
                    sortName = [char(xObject.GetName) ' - ' ...
                        'Inside ' rgnSortString];

                else
                    sortName = [char(xObject.GetName) ' - ' ...
                        'Outside ' rgnSortString];

                end % if

                % Set the name of the Imaris object.
                sortSurfaces.SetName(sortName)

                %% Set the sorted Surfaces.
                % Update the status bar.
                hStatus.setText(['Sorting ' rgnSortString])
                hStatus.ProgressBar.setMaximum(length(inIdxs))
                hStatus.ProgressBar.setVisible(true)

                % Add the indicated surfaces to the sorted Surfaces.
                if strfind(char(xImarisApp.GetVersion()),' 9.')
                    sortSurfaces = xObject.CopySurfaces(inIdxs);
                    sortSurfaces.SetName(sortName);
                    xScene.AddChild(sortSurfaces,-1);
                else
                    for s = 1:length(inIdxs)
                        % Get the surface data for the current index.
                        sNormals = xObject.GetNormals(inIdxs(s));
                        sTime = xObject.GetTimeIndex(inIdxs(s));
                        sTriangles = xObject.GetTriangles(inIdxs(s));
                        sVertices = xObject.GetVertices(inIdxs(s));

                        % Add the surface to the sorted Surface using the data.
                        sortSurfaces.AddSurface(sVertices, sTriangles, sNormals, sTime)

                        % Update the progress bar.
                        hStatus.ProgressBar.setValue(s)
                    end % for s

                    % Place the sorted Surfaces into the Imaris scene.
                    xScene.AddChild(sortSurfaces, -1)
                end

            end % if

    end % switch

    %% Update the list of Surpass objects in the base GUI.
    surpassObjects = xtgetsporfaces(xImarisApp);

    % Get the base GUI's objects popup.
    popupObjects = findobj(figSortomato, 'Tag', 'popupObjects');
    set(popupObjects, 'String', {surpassObjects.Name})

    % Store the updated object list in the the listboxes app data.
    setappdata(popupObjects, 'surpassObjects', surpassObjects)

    %% Reset the status and progress bars.
    hStatus.setText('')
    hStatus.ProgressBar.setValue(0)
    hStatus.ProgressBar.setVisible(false)
end % sortomatographpushregionsort