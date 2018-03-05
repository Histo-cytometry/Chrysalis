function popupobjectscallback(popupObjects, eventData, hSortomatoBase)
    % POPUPOBJECTSCALLBACK Callback for sortomatobase popup menu
    %   Detailed explanation goes here
    %
    %   ©2010-2013, P. Beemiller. Licensed under a Creative Commmons Attribution
    %   license. Please see: http://creativecommons.org/licenses/by/3.0/
    %

    %% Get the selected Surpass object.
    xImarisApp = getappdata(hSortomatoBase, 'xImarisApp');
    surpassObjects = getappdata(popupObjects, 'surpassObjects');
    
    listValue = get(popupObjects, 'Value');
    xObject = surpassObjects(listValue).ImarisObject;
    
    %% Update the status bar.
    statusbar(hSortomatoBase, 'Getting statistics');
    
    %% Get the statistics from Imaris.
    statStruct = xtgetstats(xImarisApp, xObject, 'ID', 'ReturnUnits', 1);

    %% Find the stats that represent single spots/surfaces and tracks.
    % We store the indices in the stats struct of spot and track stats. This
    % lets us quickly mask to use spot or track stats as selected by users.
    trackStatIdxs = strncmp('Track ', {statStruct.Name}, 6);
    singletStatIdxs = ~trackStatIdxs;
    
    %% Set the data export, graph and stat math callbacks.
    if any(get(hSortomatoBase, 'Color'))
        fColor = 'k';
        
    else
        fColor = 'w';
        
    end % if
    
    % Update the popup string color to reflect that an object has been
    % selected.
    set(popupObjects, 'ForegroundColor', fColor)
    
    % Update the export, graph and stat math callbacks.
    pushExportStats = findobj(hSortomatoBase, 'Tag', 'pushExportStats');
    set(pushExportStats, 'Callback', {@pushexportstatscallback, ...
        xImarisApp, xObject, hSortomatoBase})
    
    pushGraph = findobj(hSortomatoBase, 'Tag', 'pushGraph');
    set(pushGraph, 'Callback', {@sortomatograph, statStruct, hSortomatoBase})
    
    pushGraph3 = findobj(hSortomatoBase, 'Tag', 'pushGraph3');
    set(pushGraph3, 'Callback', {@sortomatograph3, statStruct, hSortomatoBase})
    
    pushStatMath = findobj(hSortomatoBase, 'Tag', 'pushStatMath');
    set(pushStatMath, 'Callback', {@statmath, statStruct, hSortomatoBase})
    
    %% Store the statistics data and selected object as appdata.
    setappdata(hSortomatoBase, 'statStruct', statStruct);
    setappdata(hSortomatoBase, 'trackStatIdxs', trackStatIdxs);
    setappdata(hSortomatoBase, 'singletStatIdxs', singletStatIdxs);
    setappdata(popupObjects, 'xObject', xObject)
    
    %% Reset the status bar.
    statusbar(hSortomatoBase, '');
end % popupobjectscallback