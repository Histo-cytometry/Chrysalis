function pushsurpassrefreshcallback(pushSurpassRefresh, eventData, hSortomatoBase, popupObjects)
    % PUSHSURPASSREFRESHCALLBACK Summary of this function goes here
    %   Detailed explanation goes here
    %
    %   ©2010-2013, P. Beemiller. Licensed under a Creative Commmons Attribution
    %   license. Please see: http://creativecommons.org/licenses/by/3.0/
    %
    
    %% Get the objects from Imaris.
    xImarisApp = getappdata(hSortomatoBase, 'xImarisApp');
    surpassObjects = xtgetsporfaces(xImarisApp);
    
    %% Find the current selection's index in the refreshed object list.
    popupList = get(popupObjects, 'String');
    popupValue = get(popupObjects, 'Value');
    currentName = popupList(popupValue);
    
    newIdx = find(strcmp({surpassObjects.Name}, currentName));
    
    if isempty(newIdx)
        newIdx = 1;
    end % if
    
    %% Update the popup.
    set(popupObjects, 'String', {surpassObjects.Name})
    set(popupObjects, 'Value', newIdx)
    
    setappdata(popupObjects, 'surpassObjects', surpassObjects)
end % pushsurpassrefreshcallback