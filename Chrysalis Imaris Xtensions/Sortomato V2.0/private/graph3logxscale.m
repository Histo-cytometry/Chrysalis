function graph3logxscale(hObject, eventData, axesGraph, axesMenu)
    % GRAPH3LOGXSCALE Set the Sortomato axes to x-log scaling
    %   Axes context menus children are:
    %       'menuAxesLogZScale'
    %       'menuAxesLogYScale'
    %       'menuAxesLogXScale'
    %       'menuAxesLogScale'
    %       'menuAxesLinearScale'
    
    %% Set the axes scaling.
    set(axesGraph, 'XScale', 'log', 'YScale', 'linear', 'ZScale', 'linear')
    
    %% Update the context menu checkbox.
    menuChildren = get(axesMenu, 'Children');
    set(menuChildren, {'Checked'}, {'off'; 'off'; 'on'; 'off'; 'off'})
end % graph3logxscale