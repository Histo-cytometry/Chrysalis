function popupgraphvariablecallback(hObject, eventData, figSortomatoGraph)
    % POPUPGRAPHVARIABLECALLBACK Change a Sortomato graph plotted data
    %   Detailed explanation goes here
    
    %% Get the stat struct and axes.
    statStruct = getappdata(figSortomatoGraph, 'statStruct');
    axesGraph = findobj(figSortomatoGraph, 'Tag', 'axesGraph');

    %% Update the x or y data based on the popup that is calling.
    switch get(hObject, 'Tag')
        
        case 'popupX'
            % Get the x-variable popup selection.
            xListIdx = get(hObject, 'Value');

            % Get the new x values to plot and x-axis label.
            xData = statStruct(xListIdx).Values;
            xlabel(statStruct(xListIdx).Name);
            setappdata(axesGraph, 'xData', xData)
            
            % Get the stored y vaules.
            yData = getappdata(axesGraph, 'yData');

        case 'popupY'
            % Get the y-variable popup selection.
            yListIdx = get(hObject, 'Value');

            % Get the new y values to plot and y-axis label.
            yData = statStruct(yListIdx).Values;
            ylabel(statStruct(yListIdx).Name);
            setappdata(axesGraph, 'yData', yData)
            
            % Get the stored x values.
            xData = getappdata(axesGraph, 'xData');

    end % switch
    
    %% Update the x-y plot.
    % Use the toggle status to switch between a contour and scatter plot.
    toggleContour = findobj(figSortomatoGraph, 'Tag', 'toggleContour');
    
    switch lower(get(toggleContour, 'State'))

        case 'on'
            %% Delete the previous contour.
            hContour = getappdata(axesGraph, 'hContour');
            delete(hContour)

            %% Generate a histogram of the data.
            % Create the raw histogram.
            contourLevels = getappdata(axesGraph, 'contourLevels');
            [xyHist, xyLocs] = hist3([yData, xData], ...
                [contourLevels contourLevels]);

            % Get the smoothing kernel.
            contourKernel = getappdata(axesGraph, 'contourKernel');

            % Smooth the histogram.
            if ~isscalar(contourKernel)
                xyHistSmooth = filter2(contourKernel, padarray(xyHist, [1 1]));
                xyHistSmooth = xyHistSmooth(2:end - 1, 2:end - 1);

            else
                xyHistSmooth = xyHist;

            end % if

            %% Create the contour plot.
            [cMatrix, hContour] = contourf(axesGraph, xyLocs{2}, xyLocs{1}, xyHistSmooth, ...
                contourLevels, 'LineColor', 'None');
            set(hContour, 'HitTest', 'off')
            uistack(hContour, 'bottom')
            set(axesGraph, 'XLimMode', 'Auto', 'YLimMode', 'Auto')

            % Store the contour handle.
            setappdata(axesGraph, 'hContour', hContour);

        case 'off'
            %% Update the dot plot.
            hScatter = getappdata(axesGraph, 'hScatter');            

            if isscalar(hScatter)
                %% Update the dot plot with all the data in one line object.
                set(hScatter, ...
                    {'XData', 'YData'}, ...
                    {xData, yData})
                
            else
                %% Update the two plot objects.
                rgnColorMask = getappdata(axesGraph, 'rgnColorMask');
                set(hScatter, ...
                    {'XData', 'YData'}, ...
                    {xData(~rgnColorMask), yData(~rgnColorMask); ...
                    xData(rgnColorMask), yData(rgnColorMask)})                
                
            end % if
            
    end % switch        
end % popupgraphvariablecallback