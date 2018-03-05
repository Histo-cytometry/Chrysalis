function togglepancallback(togglePan, eventData, figSortomatoGraph)
    % TOGGLEPANCALLBACK Toggle interactive axes pan
    %   Detailed explanation goes here
    
    %% Untoggle the data cursor and zoom buttons.
    toggleDataCursor = findobj(figSortomatoGraph, 'Tag', 'toggleDataCursor');
    toggleZoom = findobj(figSortomatoGraph, 'Tag', 'toggleZoom');
    toggleRotate = findobj(figSortomatoGraph, 'Tag', 'toggleRotate');
    
    set([toggleDataCursor, toggleZoom, toggleRotate], 'State', 'off')
    
    %% Toggle pan.
    if strcmp(get(togglePan, 'State'), 'on')
        pan(figSortomatoGraph, 'on')
        
    else
        pan(figSortomatoGraph, 'off')
        
    end % if
end % togglepancallback