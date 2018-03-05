function togglerotatecallback(toggleRotate, eventData, figSortomatoGraph)
    % TOGGLEROTATECALLBACK Toggle interactive axes rotate
    %   Detailed explanation goes here
    
    %% Untoggle the data cursor and pan buttons.
    toggleDataCursor = findobj(figSortomatoGraph, 'Tag', 'toggleDataCursor');
    togglePan = findobj(figSortomatoGraph, 'Tag', 'togglePan');
    toggleZoom = findobj(figSortomatoGraph, 'Tag', 'toggleZoom');
    
    set([toggleDataCursor, togglePan, toggleZoom], 'State', 'off')
    
    %% Toggle rotate.
    if strcmp(get(toggleRotate, 'State'), 'on')
        rotate3d(figSortomatoGraph, 'on')
        
    else
        rotate3d(figSortomatoGraph, 'off')
        
    end % if
end % togglerotatecallback