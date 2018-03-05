function graph3logscale(hObject, eventData, axesGraph, axesMenu)
    % GRAPH3LOGSCALE Set the Sortomato axes to log scaling
    %   Axes context menus children are:
    %       'menuAxesLogZScale'
    %       'menuAxesLogYScale'
    %       'menuAxesLogXScale'
    %       'menuAxesLogScale'
    %       'menuAxesLinearScale'
    
    %% Set the axes scaling.
    set(axesGraph, 'XScale', 'log', 'YScale', 'log', 'ZScale', 'log')
    
    %% Update the context menu checkbox.
    menuChildren = get(axesMenu, 'Children');
    set(menuChildren, {'Checked'}, {'off'; 'off'; 'off'; 'on'; 'off'})
end % graph3logscale