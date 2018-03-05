function graphlogxscale(hObject, eventData, axesGraph, axesMenu)
    % GRAPHLOGXSCALE Set the Sortomato axes to x-log scaling
    %   Axes context menus children are:
    %       'menuAxesLogYScale'
    %       'menuAxesLogXScale'
    %       'menuAxesLogScale'
    %       'menuAxesLinearScale'
    
    %% Set the axes scaling.
    set(axesGraph, 'XScale', 'log', 'YScale', 'linear')
    
    %% Update the context menu checkbox.
    menuChildren = get(axesMenu, 'Children');
    set(menuChildren, {'Checked'}, {'off'; 'on'; 'off'; 'off'})
end % graphlogxscale