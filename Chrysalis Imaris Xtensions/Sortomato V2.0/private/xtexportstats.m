function xtexportstats(statStruct, xImarisApp, xObject, varargin)
    % XTSTATEXPORT Export GUI for Imaris statistic data
    %   XTSTATEXPORT is a graphical interface to export track data imported
    %   from Imaris to an Excel file organized by track (1 track per
    %   column).
    %
    %   Syntax
    %   ------
    %   xtexportstats(statStruct, xImarisApp, xObject)
    %   xtexportstats(..., hBase)
    %   xtexportstats(..., 'Color', 'k')
    %
    %   Description 
    %   ----------- 
    %   xtexportstats(statStruct, xImarisApp, xObject) writes the data
    %   organized in the structure statStruct with fields 'Ids', 'Name',
    %   'Values' for the xObject Surpass object in the Imaris application
    %   instance xImarisApp. The function prompts for a file name to use to
    %   save the data to an Excel file.
    %
    %   xtexportstats(..., hBase) centers the export GUI over the figure
    %   represented by the handle hBase.
    %   
    %   xtexportstats(..., 'Color', 'k') creates an export GUI with a black
    %   background and light foreground elements.
    %
    %   Input Arguments
    %   ---------------
    %   statStruct      A struct with fields 'Ids', 'Name' and 'Values'
    %   xImarisApp      An <Imaris.IApplicationPrxHelper> object
    %   xObject         A Spots or Surfaces <Imaris.IDataItemPrxHelper>
    %   hBase           A valid figure handle
    %   'Color'         A paramater/value pair specifying the figure color
    %                       Valid values: 'k' and 'w'
    %
    
    %% Parse the inputs.
    xtexportstatsParser = inputParser;
    
    validationFcnArg1 = @(arg)all(isfield(arg, {'Ids', 'Name', 'Values'}));
    addRequired(xtexportstatsParser, 'statStruct', validationFcnArg1)
    
    addRequired(xtexportstatsParser, 'xImarisApp', ...
        @(arg)isa(arg, 'Imaris.IApplicationPrxHelper'))
    
    validateObjectArg = @(arg)validatextobjectarg(arg, xImarisApp);
    addRequired(xtexportstatsParser, 'xObject', validateObjectArg)
    
    addOptional(xtexportstatsParser, 'parentHandle', 0, @ishandle)
    
    addParamValue(xtexportstatsParser, 'Color', 'w', ...
        @(arg)any(strcmpi(arg, {'k', 'black', 'w', 'white'})))
    
    parse(xtexportstatsParser, statStruct, xImarisApp, xObject, varargin{:})
    
    %% Process the statistics to present only track data.
    summaryStatRegexpString = [...
        '(Number of Spots per Time Point)|' ...
        '(Number of Tracks)|' ...
        '(Total Number of Spots)|' ...
        '(Number of Disconnected Components)|' ...
        '(Number of Disconnected Components per Time Point)|' ...
        '(Number of Surfaces per Time Point)|' ...
        '(Total Number of Disconnected Components)|' ...
        '(Total Number of Surfaces)|' ...
        '(Total Number of Triangles)|' ...
        '(Total Number of Voxels)|'];

        % Find the non-summary stats.
        nonSummaryStatIdxs = cellfun(@isempty, ...
            regexp({statStruct.Name}, summaryStatRegexpString, ...
            'Match', 'Once'));

        % Find the track stats.
        trackStatIdxs = strncmp('Track ', {statStruct.Name}, 6);

        % Mask the stat structure on the non-summary & non-track
        % statistics.
        statStruct = statStruct(nonSummaryStatIdxs & ~trackStatIdxs);
        
    %% Set the figure and font colors.
    switch xtexportstatsParser.Results.Color
        
        case 'k'
            bColor = 'k';
            bColorJava = java.awt.Color.black;
            fColor = 'w';
            
        case 'w'
            bColor = 'w';
            bColorJava = java.awt.Color.white;
            fColor = 'k';
            
    end % switch
    
    %% Create the selection GUI elements.
    guiWidth = 230;
    guiHeight = 449;

    if xtexportstatsParser.Results.parentHandle == 0
        referencePos = get(0, 'MonitorPositions');
        guiPos = [...
            referencePos(1, 1) + referencePos(1, 3)/2 - guiWidth/2, ...
            referencePos(1, 2) + referencePos(1, 4)/2 - guiHeight/2, ...
            guiWidth, ...
            guiHeight];
        
    else
        referencePos = get(xtexportstatsParser.Results.parentHandle, 'Position');
        guiPos = [...
            referencePos(1, 1) + 25, ...
            referencePos(1, 2) + referencePos(1, 4) - guiHeight - 23, ...
            guiWidth, ...
            guiHeight]; 
        
    end % if
        
    hStatExport = figure(...
        'CloseRequestFcn', {@closegui}, ...
        'Color', bColor, ...
        'MenuBar', 'None', ...
        'Name', 'Statistics export', ...
        'NumberTitle', 'Off', ...
        'Position', guiPos, ...
        'Resize', 'Off', ...
        'Tag', 'hStatExport', ...
        'WindowStyle', 'Modal');

    %% Create the selection GUI elements.
    objectName = char(xObject.GetName);

    uicontrol(...
        'BackgroundColor', bColor, ...
        'FontSize', 12, ...
        'ForegroundColor', fColor, ...
        'HorizontalAlignment', 'Left', ...
        'Parent', hStatExport, ...
        'Position', [10 405 210 24], ...
        'String', [objectName ' statistics'], ...
        'Style', 'text', ...
        'Tag', 'textStatistics');

    statNames = {statStruct.Name};
    listStats = uicontrol(...
        'BackgroundColor', bColor, ...
        'FontSize', 10, ...
        'ForegroundColor', fColor, ...
        'Min', 1, ...
        'Max', 3, ...
        'Parent', hStatExport, ...
        'Position', [10 105 210 300], ...
        'String', statNames, ...
        'Style', 'listbox', ...
        'Tag', 'textStatistics', ...
        'TooltipString', 'Select stats to export to Excel');
    
    checkAlign = uicontrol(...
        'BackgroundColor', bColor, ...
        'FontSize', 10, ...
        'ForegroundColor', fColor, ...
        'Parent', hStatExport, ...
        'Position', [10 70 180 20], ...
        'String', 'Align all tracks to time zero', ...
        'Style', 'checkbox', ...
        'Tag', 'checkAlign', ...
        'TooltipString', 'Check to place the start of all tracks at the first time point');
    
    uicontrol(...
        'BackgroundColor', bColor, ...
        'Callback', {@exportstats}, ...
        'FontSize', 12, ...
        'ForegroundColor', fColor, ...
        'Parent', hStatExport, ...
        'Position', [130 40 90 24], ...
        'String', 'Export', ...
        'Style', 'pushbutton', ...
        'Tag', 'pushClose', ...
        'TooltipString', 'Press to export the selected data to Excel');
    
    %% Setup the status bar.
    hStatus = statusbar(hStatExport, '');
    hStatus.CornerGrip.setVisible(false)

    hStatus.ProgressBar.setForeground(bColorJava)
    hStatus.ProgressBar.setString('')
    hStatus.ProgressBar.setStringPainted(true)
    hStatus.ProgressBar.setValue(0)
    
    %% Nested function to close the GUI
    function closegui(varargin)
        % CLOSEGUI Close the statistic export GUI
        %
        %   This is a placeholder.
        
        %%
        delete(hStatExport)
    end % pushclose
    
    %% Nested function to export the selected data.
    function exportstats(varargin)
        % EXPORTSTATS Formats the data and writes to Excel 
        %
        %
        
        %% Have the user choose a file to write.
        % Get the Imaris source file information.
        [sourceFolder, sourceFile] = fileparts(char(xImarisApp.GetCurrentFileName));
        exportName = [sourceFile ' - ' objectName ' Track Data.xlsx'];

        % Have the user specify the file information.
        [xlFile, xlFolder] = uiputfile(...
            {'*.xlsx', 'Excel Workbook (.xlsx)'; ...
            '*.xls', 'Excel 97-2003 Workbook (.xls)'}, ...
            'Save Graph Data', fullfile(sourceFolder, exportName));
        
        if ~ischar(xlFile)
            return
        end % if
        
        xlExt = lower(regexp(xlFile, 'xlsx|xls$', 'Match' , 'Once'));
        xlPath = fullfile(xlFolder, xlFile);
                
        %% Update the status bar.
        hStatus.ProgressBar.setVisible(true)
        hStatus.setText('Organizing data')
        
        %% Get the indices of the statistics to export.
        statExportIdxs = get(listStats, 'Value');
        
        %% If the user cancelled, return.
        if isempty(statExportIdxs)
            return
        end

        %% Cast the Surpass object and get the track information.
        iFactory = xImarisApp.GetFactory;

        if iFactory.IsSpots(xObject)
            %% Cast to Spots.
            xObject = iFactory.ToSpots(xObject);

            %% Get the track ID and edge lists.
            trackIDs = xObject.GetTrackIds;
            trackEdges = xObject.GetTrackEdges;
            objectTimes = xObject.GetIndicesT;

        else
            %% Cast to Surfaces.
            xObject = iFactory.ToSurfaces(xObject);

            %% Get the track ID and edge lists.
            trackIDs = xObject.GetTrackIds;
            trackEdges = xObject.GetTrackEdges;
            objectTimes = zeros(xObject.GetNumberOfSurfaces, 1);

            for r = 1:length(objectTimes)
                objectTimes(r) = xObject.GetTimeIndex(r - 1);
            end % for r

        end % if

        %% Get the time points. These will be placed in the first column in Excel.
        timeLabels = unique(objectTimes);
        
        %% Get the track labels. These will be placed in the first row in Excel.
        trackLabels = unique(trackIDs);
        
        % If there is no track data, don't export.
        if isempty(trackLabels)
            hStatus.setText('No track data found')
            hStatus.ProgressBar.setVisible(false)
            
            return
        end % if
        
        %% Organize the data.
        %% Pre-allocate an mxnxp cell array to hold the data to write to Excel.
        % m = number of time points; n = number of tracks; p = number of stats.
        xlCell = cell(length(timeLabels) + 1, length(trackLabels) + 3, ...
            length(statExportIdxs));

        %% Write the time and track labels to the cell array.
        xlCell(2:end, 1, :) = num2cell(repmat(timeLabels, ...
            [1, 1, size(xlCell, 3)]));
        xlCell(1, 1, :) = repmat({'Time'}, ...
            [1, 1, size(xlCell, 3)]); 
        xlCell(1, 4:end, :) = num2cell(repmat(trackLabels', ...
            [1, 1, size(xlCell, 3)]));

        %% Add the average and standard deviation formulas to the cell array.
        % Create a generic version of the average formula for Excel. Use
        % x in place of the row numbers.
        avgBase = {['=AVERAGE(Dx:' xlscol(length(trackLabels) + 3) 'x)']};
        
        % Replicate the basic formula for all time points (equal to the fill down
        % operation in Excel.)
        avgColumn = repmat(avgBase, [length(timeLabels), 1]);
        
        % Create a generic version of the standard deviation formula for Excel. Use
        % x in place of the row numbers.
        switch xlExt
            
            case 'xlsx'
                stdBase = {['=STDEV.S(Dx:' xlscol(length(trackLabels) + 3) 'x)']};
                
            case 'xls'
                stdBase = {['=STDEV(Dx:' xlscol(length(trackLabels) + 3) 'x)']};
                
        end % switch
        
        % Replicate the basic formula for all time points (equal to the fill down
        % operation in Excel.)
        stdCol = repmat(stdBase, [length(timeLabels), 1]);
        
        % Create the list of row numbers to drop into the formula cell.
        xlRows = num2cell(transpose(2:length(timeLabels) + 1));
        xlRows = cellfun(@num2str, xlRows, 'UniformOutput', 0);
        
        % Create a cell array of "x"s to use as the search string for each row.
        % (We need to do this because we're going to call regexprep through
        % cellfun, so all inputs must be the same length).
        searchStr = repmat({'x'}, [length(timeLabels), 1]);
        
        % Call regexprep through cellfun to replace the x's in the formulas with
        % the appropriate row value.
        avgColumn = cellfun(@regexprep, avgColumn, searchStr, xlRows, ...
            'UniformOutput', 0);
        stdColumn = cellfun(@regexprep, stdCol, searchStr, xlRows, ...
            'UniformOutput', 0);
        
        % Add the formula strings to the cell array.
        xlCell(:, 2, :) = repmat(['Average'; avgColumn], ...
            [1, 1, size(xlCell, 3)]);
        xlCell(:, 3, :) = repmat(['Std. Dev.'; stdColumn], ...
            [1, 1, size(xlCell, 3)]);
        
        %% Sort the data by track and place the values into the cell array.
        % Update the progress bar.
        hStatus.ProgressBar.setMaximum(length(trackLabels))

        for r = 1:length(trackLabels);
            % Get the singlets that makeup the track.
            rTrackEdges = trackEdges(trackIDs == trackLabels(r), :);
            rTrackIds = double(unique(rTrackEdges));

            % Get the track timepoints.
            rTrackTimes = objectTimes(rTrackIds + 1);

            % Shift the track to start the first time point if requested.
            if get(checkAlign, 'Value')
                rTrackTimes = rTrackTimes - rTrackTimes(1);
            end % if

            % Get the row indices to place the data.
            rowIdxs = [false; ismember(timeLabels, rTrackTimes)];

            % Place the data for all the requested stats into the cell array.
            for p = 1:length(statExportIdxs)
                % Find the indexes in the Stat Struct for the Ids.
                statIdxs = ismember(statStruct(statExportIdxs(p)).Ids, rTrackIds);

                % Add the values to the cell.
                xlCell(rowIdxs, r + 3, p) = num2cell(...
                    statStruct(statExportIdxs(p)).Values(statIdxs));
            end % for p

            hStatus.ProgressBar.setValue(r)
        end % for r

        %% Write the file.
        % Update the progress bar.
        hStatus.setText('Exporting statistics')
        hStatus.ProgressBar.setMaximum(length(statExportIdxs))

        warning('off', 'MATLAB:xlswrite:AddSheet')

        % Write the track data to Excel.
        for p = 1:length(statExportIdxs)
            % Create an Excel safe worksheet name.
            pSheetName = regexprep(statNames{statExportIdxs(p)}, 'Channel', 'Ch');
            pSheetName = pSheetName(1:min([31, length(pSheetName)]));

            try
                xlswrite(xlPath, xlCell(:, :, p), pSheetName, 'A1')
            
            catch xlswriteME
                hStatus.setText('Cannot write to Excel file.')
                
            end % try
            
            hStatus.ProgressBar.setValue(p)
        end % for p

        warning('on', 'MATLAB:xlswrite:AddSheet')

        %% Reset the status bar.
        hStatus.setText('')
        hStatus.ProgressBar.setValue(0)
        hStatus.ProgressBar.setVisible(0)
    end % pushexport
end % xtstatexport


function isValidXTObject = validatextobjectarg(xObject, xImarisApp)
    % VALIDATEXTOBJECTARG Tests whether the xObject input is a valid Imaris
    % Spots or Surfaces object.
    %
    %
    
    %% Check the object input.
    switch class(xObject)
    
        case 'Imaris.ISpotsPrxHelper'
            isValidXTObject = 1;
            
        case 'Imaris.ISurfacesPrxHelper'
            isValidXTObject = 1;
            
        case 'Imaris.IDataItemPrxHelper'
            isSpots = ~isempty(xImarisApp.GetFactory.ToSpots(xObject));
            isSurfaces = ~isempty(xImarisApp.GetFactory.ToSurfaces(xObject));
            isValidXTObject = isSpots | isSurfaces;
        
        otherwise
            isValidXTObject = 0;
        
    end % if    
end % validatextobjectarg