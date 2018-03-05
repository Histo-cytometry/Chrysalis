function pushregioncreatecallback(hObject, eventData, figSortomatoGraph)
    % PUSHREGIONCREATECALLBACK Create an ROI in the SortomatoGraph
    %   Detailed explanation goes here
    %
    %   ©2010-2013, P. Beemiller. Licensed under a Creative Commmons Attribution
    %   license. Please see: http://creativecommons.org/licenses/by/3.0/
    %
    
    %% Get the graph axes.
    axesGraph = findobj(figSortomatoGraph, 'Tag', 'axesGraph');
    
    %% If the user is already drawing a region, return. 
    if getappdata(axesGraph, 'isUserDrawing')
        return
    end % if
    
    %% Update the drawing variable.
    setappdata(axesGraph, 'isUserDrawing', 1)

    %% Get the regions popup.
    popupRegions = findobj(figSortomatoGraph, 'Tag', 'popupRegions');
    
    %% Get the region tracking variables.
    % Get the color tracking variable and select the new region's color.
    colorOrder = get(axesGraph, 'ColorOrder');
    lastRegionColor = getappdata(axesGraph, 'lastRegionColor');
    colorChoice = colorOrder(rem(lastRegionColor, 9) + 1, :);
    
    % Get the struct of regions, counting variable and the Tags list.
    regionStruct = getappdata(axesGraph, 'regionStruct');
    nextRegionTag = getappdata(axesGraph, 'nextRegionTag');

    %% Start interactive creation of a new region.
    switch get(hObject, 'Tag')
        
        case 'pushEllipse'
            %% Interactively create an ellipse region.
            drawRegion = sortomatoellipse(axesGraph);

            %% If the user completes drawing of the region, add it to the list.
            if ~isempty(drawRegion)
                % Set the region color.
                drawRegion.setColor(colorChoice)

                % Add the region text label.
                drawRegion.Name = ['Ellipse ' num2str(nextRegionTag(1))];
                drawRegion.setLabel

                % Add the ellipse to the region struct.
                if ~isfield(regionStruct, 'Ellipse')
                    regionStruct.Ellipse = drawRegion;
                
                else 
                    regionStruct.Ellipse(end + 1) = drawRegion;
                    
                end % if
                    
                % Increment the tag to use for the next ellipse.
                nextRegionTag(1) = nextRegionTag(1) + 1;
            end % if

        case 'pushPolygon'
            %% Interactively create a polygon region.
            drawRegion = sortomatopoly(axesGraph);

            %% If the user completes drawing of the region, add it to the list.
            if ~isempty(drawRegion)
                % Set the new region color.
                drawRegion.setColor(colorChoice)

                % Add the region text label.
                drawRegion.Name = ['Polygon ' num2str(nextRegionTag(2))];
                drawRegion.setLabel
                
                % Add the polygon to the region struct.
                if ~isfield(regionStruct, 'Poly')
                    regionStruct.Poly = drawRegion;
                
                else 
                    regionStruct.Poly(end + 1) = drawRegion;
                    
                end % if

                % Increment the tag to use for the next polygon.
                nextRegionTag(2) = nextRegionTag(2) + 1;
            end % if

        case 'pushRectangle'
            %% Interactively create a rectangle region.
            drawRegion = sortomatorect(axesGraph);

            %% If the user completes drawing of the region, add it to the list.
            if ~isempty(drawRegion)
                % Set the new region color.
                drawRegion.setColor(colorChoice)

                % Add the region text label.
                drawRegion.Name = ['Rectangle ' num2str(nextRegionTag(3))];
                drawRegion.setLabel
                
                % Add the rectangle to the region struct.
                if ~isfield(regionStruct, 'Rect')
                    regionStruct.Rect = drawRegion;
                
                else 
                    regionStruct.Rect(end + 1) = drawRegion;
                    
                end % if

                % Increment the index to use for the next rectangle.
                nextRegionTag(3) = nextRegionTag(3) + 1;
            end % if

        case 'pushFreehand'
            %% Interactively create a freehand region.
            drawRegion = sortomatofreehand(axesGraph);

            %% If the user completes drawing of the region, add it to the list.
            if ~isempty(drawRegion)
                % Set the new region color.
                drawRegion.setColor(colorChoice)

                % Add the region text label.
                drawRegion.Name = ['Freehand ' num2str(nextRegionTag(4))];
                drawRegion.setLabel

                % Add the freehand region to the region struct.
                if ~isfield(regionStruct, 'Freehand')
                    regionStruct.Freehand = drawRegion;
                
                else 
                    regionStruct.Freehand(end + 1) = drawRegion;
                    
                end % if

                % Increment the index to use for the next freehand region.
                nextRegionTag(4) = nextRegionTag(4) + 1;
            end % if

    end % switch
    
    %% Reset the drawing variable to the non-drawing state.
    setappdata(axesGraph, 'isUserDrawing', 0)            
            
    %% If a new region was created, update the region popup menu.
    if ~isempty(drawRegion)
        popupString = get(popupRegions, 'String');
        
        if strcmp(popupString, ' ')
            popupString = {drawRegion.Name};
            
        else
            popupString = [get(popupRegions, 'String'); {drawRegion.Name}];
            
        end % if
        
        set(popupRegions, ...
            'String', popupString, ...
            'Value', length(popupString))

        %% Update the stored region tracking variables.
        % Update and store the last used color variable.
        setappdata(axesGraph, 'lastRegionColor', lastRegionColor + 1);

        % Store the region struct, counting variable and the names list.
        setappdata(axesGraph, 'regionStruct', regionStruct)
        setappdata(axesGraph, 'nextRegionTag', nextRegionTag)
    end % if
end % pushregioncreatecallback