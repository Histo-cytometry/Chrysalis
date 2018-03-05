function pushexportstatscallback(pushExportStats, eventData, xImarisApp, xObject, hSortomatoBase)
    % EXPORTSTATS Export selected statistics from the Sortomato
    %   SORTOMATOEXPORTSTATS is a wrapper for the xtexportstats function.
    %   Type help xtexportstats for more information.
    %
    %   ©2013, P. Beemiller. Licensed under a Creative Commmons Attribution
    %   license. Please see: http://creativecommons.org/licenses/by/3.0/
    %
    
    %% Get the stat struct.
    statStruct = getappdata(hSortomatoBase, 'statStruct');
    
    %% Call the xtexportstats function.
    if all(get(hSortomatoBase, 'Color') == [0 0 0])
        bColor = 'k';
        
    else
        bColor = 'w';
        
    end % if
        
    xtexportstats(statStruct, xImarisApp, xObject, hSortomatoBase, 'Color', bColor)
    
end % pushexportstatscallback

