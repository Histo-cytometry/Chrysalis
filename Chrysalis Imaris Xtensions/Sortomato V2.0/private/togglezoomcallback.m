function togglezoomcallback(toggleZoom, eventData, figSortomatoGraph)
    % TOGGLEZOOMCALLBACK Toggle interactive axes zoom
    %   Detailed explanation goes here
    
    %% Untoggle the data cursor and pan buttons.
    toggleDataCursor = findobj(figSortomatoGraph, 'Tag', 'toggleDataCursor');
    togglePan = findobj(figSortomatoGraph, 'Tag', 'togglePan');
    toggleRotate = findobj(figSortomatoGraph, 'Tag', 'toggleRotate');
    
    set([toggleDataCursor, togglePan, toggleRotate], 'State', 'off')
    
    %% Toggle zoom.
    if strcmp(get(toggleZoom, 'State'), 'on')
        zoom(figSortomatoGraph, 'on')
        
    else
        zoom(figSortomatoGraph, 'off')
        
    end % if
end % togglezoomcallback