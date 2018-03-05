function statderivatives(hObject, eventData, guiSortomato)
    % STATDERIVATIVES Calculate track statistic derivatives
    %   Detailed explanation goes here
    %
    %  ©2010-2013, P. Beemiller. Licensed under a Creative Commmons Attribution
    %  license. Please see: http://creativecommons.org/licenses/by/3.0/
    %
   
    %% Check for an already-running GUI.
    guiChildren = getappdata(guiSortomato, 'guiChildren');
    
    if ~isempty(guiChildren)
        guiStatDerivatives = findobj(guiChildren, 'Tag', 'guiStatDerivatives');
        
        if ~isempty(guiStatDerivatives)
            figure(guiStatDerivatives)
            return
        end % if
    end % if
    
    %% Get the Surpass Spots and Surfaces.
    xImarisApp = getappdata(guiSortomato, 'xImarisApp');
    surpassObjects = xtgetsporfaces(xImarisApp, 'Both');
    
    % If the scene has no Spots or Surfaces, return.
    if isempty(surpassObjects)
        return
    end % if
    
    %% Set the figure and font colors.
    if all(get(guiSortomato, 'Color') == [0 0 0])
        bColor = 'k';
        fColor = 'w';

    else
        bColor = 'w';
        fColor = 'k';
        
    end % if
    
    %% Create a GUI to select an object and statistics to calculate derivatives.
    sortomatoPos = get(guiSortomato, 'Position');
    
    guiWidth = 230;
    guiHeight = 333;
    guiPos = [...
        sortomatoPos(1) + sortomatoPos(3)/2 - guiWidth/2, ...
        sortomatoPos(2) + sortomatoPos(4) - guiHeight - 25, ...
        guiWidth, ...
        guiHeight];
    
    guiStatDerivatives = figure(...
        'CloseRequestFcn', {@closerequestfcn, guiSortomato}, ...
        'Color', bColor, ...
        'MenuBar', 'None', ...
        'Name', 'Statistic derivative calculation', ...
        'NumberTitle', 'Off', ...
        'Position', guiPos, ...
        'Resize', 'Off', ...
        'Tag', 'guiStatDerivatives');
    
    % Create the Surpass object refresh button.
    uicontrol(...
        'BackgroundColor', bColor, ...
        'Callback', {@pushsurpassrefresh, guiStatDerivatives, xImarisApp}, ...
        'CData', get(hObject, 'UserData'), ...
        'Parent', guiStatDerivatives, ...
        'Position', [10 288 24 24], ...
        'String', '', ...
        'Style', 'Pushbutton', ...
        'Tag', 'pushRefresh', ...
        'TooltipString', 'Refresh the Imaris channels');
    
    % Create a list of Surpass spots and surfaces.
    uicontrol(...
        'Background', bColor, ...
        'FontSize', 12, ...
        'Foreground', fColor, ...
        'HorizontalAlign', 'Left', ...
        'Position', [40 286 108 24], ...
        'String', 'Objects', ...
        'Style', 'text', ...
        'Tag', 'textObjects');
    
    % Sync the default selection to the base object selection.
    popupObjectsBase = findobj(guiSortomato, 'Tag', 'popupObjects');
    baseObjectSelection = get(popupObjectsBase, 'Value');
    
    popupObjects = uicontrol(...
        'Background', bColor, ...
        'Callback', {@popupobjectscallback}, ...
        'FontSize', 12, ...
        'Foreground', fColor, ...
        'Parent', guiStatDerivatives, ...
        'Position', [120 290 100 24], ...
        'String', {surpassObjects.Name}, ...
        'Style', 'popupmenu', ...
        'Tag', 'popupObjects', ...
        'TooltipString', 'Select objects for derivative calculations', ...
        'Value', baseObjectSelection);
    
    % Create the statistic selection listbox.
    uicontrol(...
        'Background', bColor, ...
        'FontSize', 12, ...
        'Foreground', fColor, ...
        'HorizontalAlign', 'Left', ...
        'Position', [10 240 108 24], ...
        'String', 'Statistics', ...
        'Style', 'text', ...
        'Tag', 'textStatistics');
    
    listStats = uicontrol(...
        'Background', bColor, ...
        'FontSize', 12, ...
        'Foreground', fColor, ...
        'Min', 1, ...
        'Max', 3, ...
        'Parent', guiStatDerivatives, ...
        'Position', [10 90 210 150], ...
        'String', {''}, ...
        'Style', 'listbox', ...
        'Tag', 'listStats', ...
        'TooltipString', 'Select statistics for derivative calculation', ...
        'Value', 1);
    
    % Create the calculate button.
    uicontrol(...
        'Background', bColor, ...
        'Callback', {@pushcalc}, ...
        'FontSize', 12, ...
        'Foreground', fColor, ...
        'FontSize', 12, ...
        'Parent', guiStatDerivatives, ...
        'Position', [130 40 90 24], ...
        'String', 'Calculate', ...
        'Style', 'pushbutton', ...
        'Tag', 'pushCalc', ...
        'TooltipString', 'Calculate statistical derivatives');
    
    %% Setup the status bar.
    hStatus = statusbar(guiStatDerivatives, '');
    hStatus.CornerGrip.setVisible(false)
    
    hStatus.ProgressBar.setForeground(java.awt.Color.black)
    hStatus.ProgressBar.setString('')
    hStatus.ProgressBar.setStringPainted(true)
    
    %% Add the GUI to the base's GUI children.
    guiChildren = getappdata(guiSortomato, 'guiChildren');
    guiChildren = [guiChildren; guiStatDerivatives];
    setappdata(guiSortomato, 'guiChildren', guiChildren)
    
    %% Nested function for object popup selection change
    function popupobjectscallback(varargin)
        % POPUPOBJECTSCALLBACK Collect statistics for the selection
        %
        %
        
        %% Check the base for the statistics list.
        % If the base has already gathered the stats for the selected
        % object, create a local copy of the stat struct.
        if get(popupObjectsBase, 'Value') == get(popupObjects, 'Value');
            statStruct = getappdata(guiSortomato, 'statStruct');
            
            if ~isempty(statStruct)
                % Limit the local stats data to singlets data.
                singletStatIdxs = getappdata(guiSortomato, 'singletStatIdxs');
                statStruct = statStruct(singletStatIdxs);
                
            else
                % Update the status bar.
                hStatus.setText('Getting statistics');
                
                % Get the object statistics.
                xObject = surpassObjects(get(popupObjects, 'Value')).ImarisObject;
                statStruct = xtgetstats(xImarisApp, xObject, 'Singlets', 'ReturnUnits', true);
                
                % Reset the status bar.
                hStatus.setText('')
                
            end % if
            
        else
            % Update the status bar.
            hStatus.setText('Getting statistics')
            
            % Get the object statistics from Imaris.
            xObject = surpassObjects(get(popupObjects, 'Value')).ImarisObject;
            
            statStruct = xtgetstats(xImarisApp, xObject, 'Singlets', 'ReturnUnits', true);
            
            % Reset the status bar.
            hStatus.setText('')
            
        end % if
                
        %% Store the stats as appdata for the stat list and update the listbox.
        setappdata(listStats, 'statStruct', statStruct)
        
        % Populate the stat list.
        set(listStats, 'String', {statStruct.Name})
    end % popupobjectscallback
    
    %% Nested function to calculate derivative statistics
    function pushcalc(varargin)
        % PUSHCALC Calculate the derivative for the selected statistics
        %
        %
        
        %% Get the list selections and statistics data.
        statSelections = get(listStats, 'Value');
        statStruct = getappdata(listStats, 'statStruct');
        
        %% Check for tracks. If there are no tracks, return.
        xObject = surpassObjects(get(popupObjects, 'Value')).ImarisObject;
        trackEdges = xObject.GetTrackEdges;
        
        if isempty(trackEdges)
            hStatus.setText('No track data found')
            return
        end % if
    
        %% Get the object track data.
        
        % Get the object time indices.
        if xImarisApp.GetFactory.IsSpots(xObject)
            % Get the spot times.
            objectTimes = xObject.GetIndicesT;

        else
            % Get the number of surfaces.
            surfaceCount = xObject.GetNumberOfSurfaces;

            % Get the surface positions and times.
            objectTimes = zeros(surfaceCount, 1);
            for s = 1:surfaceCount
                objectTimes(s) = xObject.GetTimeIndex(s - 1);
            end % s

        end % if        
        
        objectNumber = length(objectTimes);
        objectIDs = transpose(0:objectNumber - 1);
        
        % Get the track data.
        trackIDs = xObject.GetTrackIds;
        trackLabels = unique(trackIDs);
        
        %% Prepare the status bar.
        hStatus.setText('Calculating derivatives')
        hStatus.ProgressBar.setValue(0)
        hStatus.ProgressBar.setMaximum(length(statSelections))
        hStatus.ProgressBar.setVisible(true)
        
        %% Get the dataset time calibration strings and convert to serial minute values.
        timeCell = cell(xImarisApp.GetDataSet.GetSizeT, 1);

        for t = 1:xImarisApp.GetDataSet.GetSizeT
            timeCell{t} = char(xImarisApp.GetDataSet.GetTimePoint(t - 1));
        end % for t

        % Convert to serial second values.
        acquireTimes = datenum(timeCell, 'yyyy-mm-dd HH:MM:SS.FFF')*(24*60*60);
                
        %% Calculate the derivative for each statistic and add it as an Imaris statistic.
        for s = 1:length(statSelections)
            %% Get the sth statistic data.
            sStats = statStruct(statSelections(s)).Values;
            
            if isempty(sStats)
                continue
            end % if
            
            sDerivatives = zeros(size(sStats), 'single');
            
            %% Caclulate the derivatives by track.
            for r = 1:length(trackLabels)
                rEdges = trackEdges(trackIDs == trackLabels(r), :);
                rObjectIdxs = unique(rEdges);
                rTimeIdxs = objectTimes(rObjectIdxs + 1);
                
                rDiffStats = diff(sStats(rObjectIdxs + 1));
                rDiffTs = diff(acquireTimes(rTimeIdxs + 1));

                sDerivatives(rObjectIdxs(2:end) + 1) = rDiffStats./rDiffTs;
            end % for r

            %% Add the derivative data to the Imaris object.
            % Create the statistic name.
            baseName = regexprep(statStruct(statSelections(s)).Name, ...
                'derivative', '2nd');
            baseName = strcat(baseName, ' derivative');
            
            % Strip any channel references (Imaris will add its own).
            baseName = regexprep(baseName, ' - Channel \d', '');
            
            % Create the name list for Imaris.
            statNames = repmat({baseName}, [objectNumber, 1]); 

            % Create the statistic unit list for Imaris.
            dataUnits = statStruct(statSelections(s)).Units;
            if ~isempty(dataUnits)
                statUnits = repmat({[dataUnits, '/s']}, [objectNumber, 1]);
                
            else
                statUnits = repmat({'Intensity/s'}, [objectNumber, 1]);
                
            end % if
            
            % Convert second derivative units from /s/s to /s^2.
            statUnits = regexprep(statUnits, '\/s/s', 's^2');
            
            % Assemble the factors cell array.
            statFactors = cell(4, objectNumber);

            % Set the Category.
            if xImarisApp.GetFactory.IsSpots(xObject)
                statFactors(1, :) = repmat({'Spot'}, [objectNumber, 1]);

            else
                statFactors(1, :) = repmat({'Surface'}, [objectNumber, 1]);

            end % if
            
            % Set the Channel.
            if ~isempty(regexp(statStruct(statSelections(s)).Name, 'Intensity', ...
                    'Start', 'Once', 'IgnoreCase'))
                % Get the channnel number from the stat name.
                channelIdx = regexp(statStruct(statSelections(s)).Name, ...
                    '((Ch=)|(Channel ))(\d)', ...
                    'Tokens');
                channelFactorList = repmat(channelIdx{1}(2), [objectNumber 1]);
                statFactors(2, :) = channelFactorList;
                
            else
                statFactors(2, :) = repmat({''}, [objectNumber 1]);
                
            end % if
            
            % Set the Collection to an empty string.
            statFactors(3, :) = repmat({''}, [objectNumber, 1]);

            % Set the Time.
            statFactors(4, :) = num2cell(objectTimes + 1);

            % Convert the time points to strings.
            statFactors(4, :) = cellfun(@num2str, statFactors(4, :), ...
                'UniformOutput', 0);

            % Create the factor names.
            factorNames = {'Category', 'Channel', 'Collection', 'Time'};

            % Send the distance statistics to Imaris.
            xObject.AddStatistics(statNames, sDerivatives, statUnits, ...
                statFactors, factorNames, objectIDs)

            % Update the progress bar.
            hStatus.ProgressBar.setValue(s)
        end % for s

        %% Reset the progress and status bars.
        hStatus.setText('')
        hStatus.ProgressBar.setValue(0)
        hStatus.ProgressBar.setVisible(false)            
    end % pushcalc    
end % statderivatives


function pushsurpassrefresh(pushSurpassRefresh, eventData, guiStatDerivatives, xImarisApp)
    % PUSHSURPASSREFRESH Summary of this function goes here
    %   Detailed explanation goes here
    %
    %   ©2010-2013, P. Beemiller. Licensed under a Creative Commmons Attribution
    %   license. Please see: http://creativecommons.org/licenses/by/3.0/
    %
    
    %% Get the objects from Imaris.
    surpassObjects = xtgetsporfaces(xImarisApp);
    
    %% Find the popup.
    popupObjects = findobj(guiStatDerivatives, 'Tag', 'popupObjects');
    
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
end % pushsurpassrefresh


function closerequestfcn(guiStatDerivatives, eventData, guiSortomato)
    % Close the sortomato sub-GUI figure
    %
    %
    
    %% Remove the GUI's handle from the base's appdata and delete.
    guiChildren = getappdata(guiSortomato, 'guiChildren');

    guiIdx = guiChildren == guiStatDerivatives;
    guiChildren = guiChildren(~guiIdx);
    setappdata(guiSortomato, 'guiChildren', guiChildren)
    delete(guiStatDerivatives);
end % closerequestfcn