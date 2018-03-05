function popupgraph3variablecallback(hObject, eventData, hSortomatoGraph)
    % POPUPGRAPH3VARIABLECALLBACK Change a Sortomato graph plotted data
    %   Detailed explanation goes here
    
    %% Get the stat struct and current plot values.
    statStruct = getappdata(hSortomatoGraph, 'statStruct');
    
    axesGraph = findobj(hSortomatoGraph, 'Tag', 'axesGraph');
    xData = getappdata(axesGraph, 'xData');
    yData = getappdata(axesGraph, 'yData');
    zData = getappdata(axesGraph, 'zData');
    
    %% Update the x, y or z data based on the popup that is calling.
    switch get(hObject, 'Tag')
        
        case 'popupX'
            % Get the x-variable popup selection.
            xListIdx = get(hObject, 'Value');

            % Get the new x-values to plot and x-axis label.
            xData = statStruct(xListIdx).Values;
            xlabel(statStruct(xListIdx).Name);
            setappdata(axesGraph, 'xData', xData)
            
        case 'popupY'
            % Get the y-variable popup selection.
            yListIdx = get(hObject, 'Value');

            % Get the new y-values to plot and y-axis label.
            yData = statStruct(yListIdx).Values;
            ylabel(statStruct(yListIdx).Name);
            setappdata(axesGraph, 'yData', yData)

        case 'popupZ'
            % Get the z-variable popup selection.
            zListIdx = get(hObject, 'Value');

            % Get the new z-values to plot and y-axis label.
            zData = statStruct(zListIdx).Values;
            zlabel(statStruct(zListIdx).Name);
            setappdata(axesGraph, 'zData', zData)

    end % switch
    
    %% Update the x-y-z plot.
    hScatter = getappdata(axesGraph, 'hScatter');
    set(hScatter, ...
        'XData', xData, ...
        'YData', yData, ...
        'ZData', zData)
end % popupgraph3variablecallback