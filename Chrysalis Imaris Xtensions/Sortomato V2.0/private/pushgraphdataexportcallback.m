function pushgraphdataexportcallback(hObject, eventData, figSortomatoGraph)
    % PUSHGRAPHDATAEXPORTCALLBACK Summary of this function goes here
    %   Detailed explanation goes here
    %
    %  ©2010-2013, P. Beemiller. Licensed under a Creative Commmons Attribution
    %  license. Please see: http://creativecommons.org/licenses/by/3.0/
    %
    
    %% Use the Imaris source file and object name to constuct a default file name.
    xImarisApp = getappdata(figSortomatoGraph, 'xImarisApp');
    [filePath, fileName] = fileparts(char(xImarisApp.GetCurrentFileName));
    
    xObject = getappdata(figSortomatoGraph, 'xObject');
    
    exportName = [fileName ' - ' char(xObject.GetName) ' Data.xls'];
    
    %% Have the user specify the file information.
    [xlFile, xlFolder] = uiputfile({...
        '*.xls', 'Excel 97-2003 Workbook (.xls)'; 
        '*.xlsx', 'Excel Workbook (.xlsx)'; 
        '*.*', 'All Files' }, ...
        'Save Graph Data', fullfile(filePath, exportName));

    %% If the user doesn't cancel, get the plot data from the graph and write the file.
    if ischar(xlFile)
        switch get(figSortomatoGraph, 'Tag')

            case 'figSortomatoGraph'
                %% Get the xy plot data.
                statStruct = getappdata(figSortomatoGraph, 'statStruct');

                axesGraph = findobj(figSortomatoGraph, 'Tag', 'axesGraph');
                xData = getappdata(axesGraph, 'xData');
                yData = getappdata(axesGraph, 'yData');

                %% If the plot is empty, return.
                if isempty(xData)
                    return
                end % if
                
                %% Get the x and y values and encapsulate the values in cells.
                xCell = num2cell(xData);
                yCell = num2cell(yData);

                %% Get the object IDs.
                % Find the index in the stat struct from the popup selection.
                popupY = findobj(figSortomatoGraph, 'Tag', 'popupY');
                statIdx = get(popupY, 'Value');

                % Get the IDs from the stat structure.
                xlIDs = statStruct(statIdx).Ids;

                % Convert to a cell.
                xlIDs = num2cell(xlIDs);

                %% Construct a cell array to write to Excel.
                xlCell = cell(length(xCell) + 1, 3);
                xlCell(1, :) = {'ID', ...
                    get(get(axesGraph, 'xlabel'), 'String'), ...
                    get(get(axesGraph, 'ylabel'), 'String')};
                xlCell(2:end, :) = [xlIDs, xCell, yCell];

                %% Write the Excel file.
                xlswrite(fullfile(xlFolder, xlFile), xlCell, 1, 'A1')

            case 'figSortomatoGraph3'
                %% Get the xy plot data.
                statStruct = getappdata(figSortomatoGraph, 'statStruct');

                axesGraph = findobj(figSortomatoGraph, 'Tag', 'axesGraph');
                xData = getappdata(axesGraph, 'xData');
                yData = getappdata(axesGraph, 'yData');
                zData = getappdata(axesGraph, 'zData');
                
                %% If the plot is empty, return.
                if isempty(xData)
                    return
                end % if
                
                %% Get the x and y values and encapsulate the values in cells.
                xCell = num2cell(xData);
                yCell = num2cell(yData);
                zCell = num2cell(zData);
                
                %% Get the object IDs.
                % Find the index in the stat struct from the popup selection.
                popupY = findobj(figSortomatoGraph, 'Tag', 'popupY');
                statIdx = get(popupY, 'Value');

                % Get the IDs from the stat structure.
                xlIDs = statStruct(statIdx).Ids;

                % Convert to a cell.
                xlIDs = num2cell(xlIDs);

                %% Construct a cell array to write to Excel.
                xlCell = cell(length(xCell) + 1, 4);
                xlCell(1, :) = {'ID', ...
                    get(get(axesGraph, 'xlabel'), 'String'), ...
                    get(get(axesGraph, 'ylabel'), 'String'), ...
                    get(get(axesGraph, 'zlabel'), 'String')};
                xlCell(2:end, :) = [xlIDs, xCell, yCell, zCell];

                %% Write the Excel file.
                xlswrite(fullfile(xlFolder, xlFile), xlCell, 1, 'A1')

        end % switch
    end % if
end % pushgraphdataexportcallback