function togglecontourcallback(hObject, eventData, figSortomatoGraph, axesGraph)
    % TOGGLECONTOURCALLBACK Toggle contour plotting of data
    %   Detailed explanation goes here
    
    %% Get the plot data.
    xData = getappdata(axesGraph, 'xData');
    yData = getappdata(axesGraph, 'yData');
    
    %% Get the settings toolbar button.
    pushContourSettings = findobj(figSortomatoGraph, 'Tag', 'pushContourSettings');
    
    %% Use the toggle status to switch between a contour and scatter plot.
    switch lower(get(hObject, 'State'))

            case 'on'
                %% Update the contouring toolbar button controls.
                set(hObject, ...
                    'CData', getappdata(hObject, 'toggleScatterCData'), ...
                    'TooltipString', 'Display data as a scatter plot')
                
                set(pushContourSettings, 'ClickedCallback', ...
                    {@contoursettings, figSortomatoGraph, axesGraph})
                
                %% Hide the scatter plot.
                hScatter = getappdata(axesGraph, 'hScatter');
                set(hScatter, ...
                    'Visible', 'Off', ...
                    'XLimInclude', 'Off', ...
                    'YLimInclude', 'Off')
                
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
                %% Update the toggle button tooltip and cdata.
                set(hObject, ...
                    'CData', getappdata(hObject, 'toggleContourCData'), ...
                    'TooltipString', 'Display data as a Contour plot')
                
                set(pushContourSettings, 'ClickedCallback', '')

                %% Remove the contour plot.
                hContour = getappdata(axesGraph, 'hContour');
                if ~isempty(hContour)
                    delete(hContour)
                    rmappdata(axesGraph, 'hContour')
                end

                %% Close the contour settings window and remove the handle appdata.
                guiContourSettings = getappdata(figSortomatoGraph, 'guiContourSettings');
                if ishandle(guiContourSettings)
                    delete(guiContourSettings)
                    rmappdata(figSortomatoGraph, 'guiContourSettings')
                end % if
                
                %% Restore the scatter plot.
                hScatter = getappdata(axesGraph, 'hScatter');            

                if isscalar(hScatter)
                    %% Update the dot plot with all the data in one line object.
                    set(hScatter, ...
                        {'XData', 'YData', 'Visible', 'XLimInclude', 'YLimInclude'}, ...
                        {xData, yData, 'On', 'On', 'On'})

                else
                    %% Divide the data into two plots and update the dot plot.
                    rgnColorMask = getappdata(axesGraph, 'rgnColorMask');
                    set(hScatter, ...
                        {'XData', 'YData'}, ...
                        {xData(~rgnColorMask), yData(~rgnColorMask); ...
                        xData(rgnColorMask), yData(rgnColorMask)})                
                    set(hScatter, ...
                        'Visible', 'On', ...
                        'XLimInclude', 'On', ...
                        'YLimInclude', 'On')

                end % if

    end % switch
end % togglecontourcallback