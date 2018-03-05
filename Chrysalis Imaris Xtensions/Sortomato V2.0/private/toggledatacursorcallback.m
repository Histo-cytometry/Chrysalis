function toggledatacursorcallback(toggleDataCursor, eventData, figSortomatoGraph)
    % toggledatacursorcallback Toggle interactive axes data cursor
    %   Detailed explanation goes here
    
    %% Untoggle the zoom and pan buttons.
    toggleZoom = findobj(figSortomatoGraph, 'Tag', 'toggleZoom');
    togglePan = findobj(figSortomatoGraph, 'Tag', 'togglePan');
    toggleRotate = findobj(figSortomatoGraph, 'Tag', 'toggleRotate');
    
    set([toggleZoom, togglePan, toggleRotate], 'State', 'off')
    
    %% Toggle data cursor.
    if strcmp(get(toggleDataCursor, 'State'), 'on')
        datacursormode(figSortomatoGraph, 'on')
        
    else
        datacursormode(figSortomatoGraph, 'off')
        
    end % if
end % toggledatacursorcallback

