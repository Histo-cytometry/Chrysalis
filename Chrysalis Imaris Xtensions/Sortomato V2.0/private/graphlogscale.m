function graphlogscale(hObject, eventData, axesGraph, axesMenu)
    % GRAPHLOGSCALE Set the Sortomato axes to log scaling
    %   Axes context menus children are:
    %       'menuAxesLogYScale'
    %       'menuAxesLogXScale'
    %       'menuAxesLogScale'
    %       'menuAxesLinearScale'
    
    %% Set the axes scaling.
    set(axesGraph, 'XScale', 'log', 'YScale', 'log')
    
    %% Update the context menu checkbox.
    menuChildren = get(axesMenu, 'Children');
    set(menuChildren, {'Checked'}, {'off'; 'off'; 'on'; 'off'})
end % graphlogscale