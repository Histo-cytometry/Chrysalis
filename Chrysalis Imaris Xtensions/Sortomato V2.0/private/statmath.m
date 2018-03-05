function statmath(hObject, eventData, statStruct, guiSortomato)
    % statmath Perform arithmetic on object statistics
    %   Detailed explanation goes here
    
    %% Check for an already-running GUI.
    guiChildren = getappdata(guiSortomato, 'guiChildren');
    
    if ~isempty(guiChildren)
        guiStatMath = findobj(guiChildren, 'Tag', 'guiStatMath');
        
        if ~isempty(guiStatMath)
            figure(guiStatMath)
            return
        end % if
    end % if
    
    %% Get the Imaris objects and statistics.
    xImarisApp = getappdata(guiSortomato, 'xImarisApp');
    
    popupObjects = findobj(guiSortomato, 'Tag', 'popupObjects');
    xObject = getappdata(popupObjects, 'xObject');
    
    %% Mask the statistics for track or singlet data.
    panelGraphType = findobj(guiSortomato, 'Tag', 'panelGraphType');
    radioSelection = get(panelGraphType, 'SelectedObject');

    switch get(radioSelection, 'Tag')

        case 'radioSinglets'
            % Keep the singlet stats.
            singletStatIdxs = getappdata(guiSortomato, 'singletStatIdxs');
            statStruct = statStruct(singletStatIdxs);

            % Set the statistical category and a get the time indices.
            if xImarisApp.GetFactory.IsSpots(xObject)
                statCategory = 'Spot';
                objectTimeIdxs = num2cell(xObject.GetIndicesT + 1);
                objectTimeIdxs = cellfun(@num2str, objectTimeIdxs, 'UniformOutput', 0);
                
            else
                statCategory = 'Surface';
                objectTimeIdxs = cell(xObject.GetNumberOfSurfaces, 1);
                for s = 1:length(objectTimeIdxs)
                    objectTimeIdxs(s) = num2cell(xObject.GetTimeIndex(s - 1) + 1);
                end % for s
                objectTimeIdxs = cellfun(@num2str, objectTimeIdxs, 'UniformOutput', 0);
                
            end % if
            
        case 'radioTracks'
            % Keep the track stats.
            trackStatIdxs = getappdata(guiSortomato, 'trackStatIdxs');
            statStruct = statStruct(trackStatIdxs);
            
            statCategory = 'Track';
            objectTimeIdxs = repmat({''}, size(statStruct(1).Values));
            
    end % switch
    
    %% Set the figure and font colors.
    if all(get(guiSortomato, 'Color') == [0 0 0])
        bColor = 'k';
        fColor = 'w';

    else
        bColor = 'w';
        fColor = 'k';
        
    end % if
    
    %% Create the figure.
    sortomatoPos = get(guiSortomato, 'Position');

    guiWidth = 230;
    guiHeight = 233;
    guiPos = [...
        sortomatoPos(1) + sortomatoPos(3)/2 - guiWidth/2, ...
        sortomatoPos(2) + sortomatoPos(4) - guiHeight - 25, ...
        guiWidth, ...
        guiHeight];
    
    guiStatMath = figure(...
        'CloseRequestFcn', {@closerequestfcn, guiSortomato}, ...
        'Color', bColor, ...
        'MenuBar', 'None', ...
        'Name', 'Stat math', ...
        'NumberTitle', 'Off', ...
        'Position', guiPos, ...
        'Resize', 'Off', ...
        'Tag', 'guiStatMath');
    
    % Create the first stat selection popup menu.
    uicontrol(...
        'Background', bColor, ...
        'FontSize', 12, ...
        'Foreground', fColor, ...
        'HorizontalAlign', 'Left', ...
        'Position', [10 186 108 24], ...
        'String', 'Value 1 (s1)', ...
        'Style', 'text', ...
        'Tag', 'textStat1');
    
    popupStat1 = uicontrol(...
        'Background', bColor, ...
        'FontSize', 12, ...
        'Foreground', fColor, ...
        'Parent', guiStatMath, ...
        'Position', [120 190 100 24], ...
        'String', {statStruct.Name}, ...
        'Style', 'popupmenu', ...
        'Tag', 'popupStat1', ...
        'TooltipString', 'Select statistics for math', ...
        'Value', 1);
    
    % Create the second stat selection popup menu.
    uicontrol(...
        'Background', bColor, ...
        'FontSize', 12, ...
        'Foreground', fColor, ...
        'HorizontalAlign', 'Left', ...
        'Position', [10 136 108 24], ...
        'String', 'Value 2 (s2)', ...
        'Style', 'text', ...
        'Tag', 'textStat2');
    
    popupStat2 = uicontrol(...
        'Background', bColor, ...
        'FontSize', 12, ...
        'Foreground', fColor, ...
        'Parent', guiStatMath, ...
        'Position', [120 140 100 24], ...
        'String', {statStruct.Name}, ...
        'Style', 'popupmenu', ...
        'Tag', 'popupStat2', ...
        'TooltipString', 'Select statistics for math', ...
        'Value', 1);
    
    % Create the expression edit box.
    uicontrol(...
        'Background', bColor, ...
        'FontSize', 12, ...
        'Foreground', fColor, ...
        'HorizontalAlign', 'Left', ...
        'Position', [10 86 108 24], ...
        'String', 'Expression', ...
        'Style', 'text', ...
        'Tag', 'textStat1');
    
    tipString = sprintf([...
        'Enter an expression:\n' ...
        '\vuse s1 and s2 as variables\n' ...
        '\vuse .* to multiply and ./ divide']);
    editExpression = uicontrol(...
        'Background', bColor, ...
        'FontSize', 12, ...
        'Foreground', fColor, ...
        'Parent', guiStatMath, ...
        'Position', [120 90 100 24], ...
        'String', 's1./s2', ...
        'Style', 'edit', ...
        'Tag', 'editExpression', ...
        'TooltipString', sprintf(tipString), ...
        'Value', 1);
        
    % Create the calculate button.
    uicontrol(...
        'Background', bColor, ...
        'Callback', {@pushcalc}, ...
        'FontSize', 12, ...
        'Foreground', fColor, ...
        'Parent', guiStatMath, ...
        'Position', [130 40 90 24], ...
        'String', 'Calculate', ...
        'Style', 'pushbutton', ...
        'Tag', 'pushCalc', ...
        'TooltipString', 'Calculate new statistic using the epxression');
    
    %% Setup the status bar.
    hStatus = statusbar(guiStatMath, '');
    hStatus.CornerGrip.setVisible(false)
    
    hStatus.ProgressBar.setForeground(java.awt.Color.black)
    hStatus.ProgressBar.setMaximum(2)
    hStatus.ProgressBar.setString('')
    hStatus.ProgressBar.setStringPainted(true)
    
    %% Add the GUI to the base's GUI children.
    guiChildren = getappdata(guiSortomato, 'guiChildren');
    guiChildren = [guiChildren; guiStatMath];
    setappdata(guiSortomato, 'guiChildren', guiChildren)
    
    %% Nested function to perform stat math
    function pushcalc(varargin)
        % PUSHCALC Calculate the statistic from the expression
        %
        %
        
        %% Setup the status bar.
        hStatus.setText('Evaluating expression')
        hStatus.ProgressBar.setValue(0)
        hStatus.ProgressBar.setVisible(1)
    
        %% Get the selected statistic data.
        % Get the first stat. Assign its data to s1.
        stat1Idx = get(popupStat1, 'Value');
        s1 = double(statStruct(stat1Idx).Values);
        
        % Get the second stat. Assign its data to s2.
        stat2Idx = get(popupStat2, 'Value');
        s2 = double(statStruct(stat2Idx).Values);
        
        %% Get the expression to calculate.
        expressionString = get(editExpression, 'String');
        
        %% Try to evaluate the expression.
        try
            %% Evaluate.
            derivedStat = eval(expressionString);
            
            %% Construct the name for the new stat.
            derivedStatName = regexprep(expressionString, 's1', statStruct(stat1Idx).Name);
            derivedStatName = regexprep(derivedStatName, 's2', statStruct(stat2Idx).Name);
            derivedStatName = regexprep(derivedStatName, '\.', '');
            
            %% Construct the unit name for the new stat.
            if ~isempty(statStruct(stat1Idx).Units) && ~isempty(statStruct(stat2Idx).Units)
                derivedStatUnit = regexprep(expressionString, 's1', statStruct(stat1Idx).Units);
                derivedStatUnit = regexprep(derivedStatUnit, 's2', statStruct(stat2Idx).Units);
                derivedStatUnit = regexprep(derivedStatUnit, '\.', '');
                
            elseif strcmp(statStruct(stat1Idx).Units, statStruct(stat2Idx).Units)
                derivedStatUnit = '';
                
            else
                derivedStatUnit = '';
                
            end % if

            %% Transfer the derived stat to Imaris.
            % Update the status and progresss bar.
            hStatus.setText('Transferring calculated statistics')
            hStatus.ProgressBar.setValue(1)

            % Create the stat name list.
            statNames = repmat({derivedStatName}, size(derivedStat));

            % Create the unit list.
            statUnits = repmat({derivedStatUnit}, size(derivedStat)); 

            % Assemble the factors cell array.
            statFactors = cell(3, length(derivedStat));

            % Set the Category.
            statFactors(1, :) = repmat({statCategory}, size(derivedStat));

            % Set the Collection to any empty string.
            statFactors(2, :) = repmat({''}, size(derivedStat));

            % Set the Time.
            statFactors(3, :) = objectTimeIdxs;
            
            % Create the factor names.
            factorNames = {'Category'; 'Collection'; 'Time'};

            % Send the stats to Imaris.
            xObject.AddStatistics(statNames, derivedStat, statUnits, ...
                statFactors, factorNames, statStruct(stat1Idx).Ids)

            % Update the progress bar.
            hStatus.ProgressBar.setValue(2)

        catch statMathError
            hStatus.ProgressBar.setString(sprintf(['Invalid variable (s1, s2, ...), ', ...
                'or operator \n\n', ...
                statMathError.message]))

        end % catch
        
        %% Add the derived value to the stat struct.
        statStruct(end + 1).Ids = statStruct(stat1Idx).Ids;
        statStruct(end).Name = derivedStatName;
        statStruct(end).Values = derivedStat;
        statStruct(end).Units = derivedStatUnit;
        
        % Sort the stats into alphabetical order.
        [sortedNames, statOrder] = sort({statStruct.Name});
        statStruct = statStruct(statOrder);
        
        %% Update the stored stat data.
        setappdata(guiSortomato, 'statStruct', statStruct)
        
        % Update the export, graph and stat math callbacks.
        pushExportStats = findobj(guiSortomato, 'Tag', 'pushExportStats');
        set(pushExportStats, 'Callback', {@sortomatobaseexportstats, ...
            xImarisApp, xObject, guiSortomato})

        pushGraph = findobj(guiSortomato, 'Tag', 'pushGraph');
        set(pushGraph, 'Callback', {@sortomatograph, statStruct, guiSortomato})

        pushGraph3 = findobj(guiSortomato, 'Tag', 'pushGraph3');
        set(pushGraph3, 'Callback', {@sortomatograph3, statStruct, guiSortomato})

        pushStatMath = findobj(guiSortomato, 'Tag', 'pushStatMath');
        set(pushStatMath, 'Callback', {@statmath, statStruct, guiSortomato})
    
        %% Update the dropdowns.
        set([popupStat1, popupStat2], 'String', {statStruct.Name})
        
        %% Reset the progress and status bars.
        hStatus.setText('')
        hStatus.ProgressBar.setValue(0)
        hStatus.ProgressBar.setVisible(false)        
    end % pushcalc
end % statmath


function closerequestfcn(guiStatMath, eventData, guiSortomato)
    % Close the sortomato sub-GUI figure
    %
    %
    
    %% Remove the GUI's handle from the base's appdata and delete.
    guiChildren = getappdata(guiSortomato, 'guiChildren');

    guiIdx = guiChildren == guiStatMath;
    guiChildren = guiChildren(~guiIdx);
    setappdata(guiSortomato, 'guiChildren', guiChildren)
    delete(guiStatMath);
end % closerequestfcn