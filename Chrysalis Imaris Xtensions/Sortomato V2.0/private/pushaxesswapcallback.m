function pushaxesswapcallback(hObject, eventData, figSortomatoGraph)
    % PUSHAXESSWAPCALLBACK Summary of this function goes here
    %   Detailed explanation goes here
    
    %% Get the current x and y listbox selections.
    popupX = findobj(figSortomatoGraph, 'Tag', 'popupX');
    currentX = get(popupX, 'Value');
    
    popupY = findobj(figSortomatoGraph, 'Tag', 'popupY');
    currentY = get(popupX, 'Value');

    %% Swap the x and y selections.
    set(popupX, 'Value', currentY);
    set(popupY, 'Value', currentX);

    %% Swap the axis labels.
    axesGraph = findobj(figSortomatoGraph, 'Tag', 'axesGraph');
    
    titleX = get(axesGraph, 'xlabel');
    currentXLabel = get(titleX, 'String');
    
    titleY = get(axesGraph, 'ylabel');
    currentYLabel = get(titleY, 'String');
    
    set(titleX, 'String', currentYLabel)
    set(titleY, 'String', currentXLabel)

    %% Swap the plot data.
    currentXValues = getappdata(axesGraph, 'xData');
    currentYValues = getappdata(axesGraph, 'yData');
    xData = currentYValues;
    yData = currentXValues;

    %% Update the x-y plot.
    % Use the toggle status to switch between a contour and scatter plot.
    toggleContour = findobj(figSortomatoGraph, 'Tag', 'toggleContour');
    
    if ~isempty(xData) && ~isempty(yData)
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
                %% Restore the scatter plot.
                hScatter = getappdata(axesGraph, 'hScatter');
                set(hScatter, ...
                    'XData', xData, ...
                    'YData', yData, ...
                    'Visible', 'On', ...
                    'XLimInclude', 'On', ...
                    'YLimInclude', 'On')

        end % switch
        
    else
        switch lower(get(toggleContour, 'State'))
            
            case 'on'
                %% Remove the contour plot.
                hContour = getappdata(axesGraph, 'hContour');
                if ~isempty(hContour)
                    delete(hContour)
                    rmappdata(axesGraph, 'hContour')
                end % if
                
            case 'off'
                % Blank the plot.
                set(getappdata(axesGraph, 'hScatter'), ...
                    'XData', [], 'YData', []);

        end % switch
        
    end % if
    
    %% Update the stored appdata.
    setappdata(axesGraph, 'xData', xData)
    setappdata(axesGraph, 'yData', yData)
end % pushaxesswapcallback