function sortomatograph(hObject, hEvent, statStruct, guiSortomato, varargin)
    % SORTOMATOGRAPH Graph and sort objects based on their properties
    %   Syntax
    %   ------
    %   SORTOMATOGRAPH(hObject, eventData, hSortomatoBase)
    %   SORTOMATOGRAPH(..., 'Color', 'k')
    %   
    %   Description
    %   -----------
    %   SORTOMATOGRAPH(hObject, eventData, hSortomatoBase) creates a
    %   sortomatograph when executed as a callback for hObject. The graph
    %   figure runs as a part of the Sortomato base GUI represented by the
    %   handle hSortomatoBase.
    %
    %   SORTOMATOGRAPH(..., 'Color', 'k') creates a sortomatograph figure
    %   with a dark background.
    %   
    %   SORTOMATOGRAPH is a GUI to create xy plots of the properties derived
    %   from segmented image objects. The plots can be used to sort the
    %   objects into new groups. SORTOMATOGRAPH is meant to be called as part of
    %   the Sortomato. Therefore, it has callback syntax (first two arguments
    %   follow the standard MATLAB syntax for callback functions).
    %
    %   ©2010-2013, P. Beemiller. Licensed under a Creative Commmons Attribution
    %   license. Please see: http://creativecommons.org/licenses/by/3.0/
    %
    
    %% Parse the inputs.
    sortomatographParser = inputParser;
    
    addRequired(sortomatographParser, 'hObject', @(arg)ishandle(arg))
    
    validationFcnArg1 = @(arg)all(isfield(arg, {'Ids', 'Name', 'Values'}));
    addRequired(sortomatographParser, 'statStruct', validationFcnArg1)
    
    addRequired(sortomatographParser, 'guiSortomato', @(arg)ishandle(arg))
    
    addOptional(sortomatographParser, 'RegionName', '', ...
        @(arg)ischar(arg))
    
    parse(sortomatographParser, hObject, statStruct, guiSortomato, varargin{:})
    
    %% Get the Imaris object and statistics.
    if get(hObject, 'Parent') == guiSortomato
        % Get the Imaris object from the base's popup menu.
        popupObjects = findobj(guiSortomato, 'Tag', 'popupObjects');
        xObject = getappdata(popupObjects, 'xObject');
        
        % Filter the statistics based on the graph type panel selection.
        panelGraphType = findobj(guiSortomato, 'Tag', 'panelGraphType');
        radioSelection = get(panelGraphType, 'SelectedObject');

        switch get(radioSelection, 'Tag')

            case 'radioSinglets'
                graphTypeString = 'Singlets';

                % Keep the singlet stats.
                singletStatIdxs = getappdata(guiSortomato, 'singletStatIdxs');
                statStruct = statStruct(singletStatIdxs);

            case 'radioTracks'
                graphTypeString = 'Tracks';

                % Keep the track stats.
                trackStatIdxs = getappdata(guiSortomato, 'trackStatIdxs');
                statStruct = statStruct(trackStatIdxs);

        end % switch
    
        % Create the graph's title and get the lower-left corner of the calling
        % figure.
        graphName = [char(xObject.GetName) ':' graphTypeString];
        referencePos = get(guiSortomato, 'Position');
        
    else
        % Get the Imaris object from the parent graph.
        if strncmp(get(hObject, 'Tag'), 'push', 4)
            figParentGraph = get(get(hObject, 'Parent'), 'Parent');

            xObject = getappdata(figParentGraph, 'xObject');

        else
            figParentGraph = get(get(get(hObject, 'Parent'), 'Parent'), 'Parent');

            xObject = getappdata(figParentGraph, 'xObject');

        end % if
        
        % Determine if it's an in-region or out-of-region plot.
        outsidePlot = ~isempty(regexp(get(hObject, 'Tag'), '(Outside)', 'Match', 'Once'));
        
        % Create the graph's title and get the lower-left corner of the calling
        % figure.
        if outsidePlot
            graphName = [get(figParentGraph, 'Name') ':Not In ' varargin{1}];
            
        else
            graphName = [get(figParentGraph, 'Name') ':In ' varargin{1}];
        
        end % if
        
        referencePos = get(figParentGraph, 'Position');
        
    end % if

    %% Create the graph figure.
    guiWidth = 450;
    guiHeight = 470;
    guiPos = [...
        referencePos(1, 1) + 25, ...
        referencePos(1, 2) + referencePos(1, 4) - guiHeight - 50, ...
        guiWidth, ...
        guiHeight]; 
    
    figSortomatoGraph = figure(...
        'CloseRequestFcn', {@graphclose, guiSortomato}, ...
        'DockControls', 'off', ...
        'InvertHardCopy', 'off', ...
        'MenuBar', 'None', ...
        'Name', graphName, ...
        'NumberTitle', 'Off', ...
        'PaperPositionMode', 'auto', ...
        'Position', guiPos, ...
        'Renderer', 'ZBuffer', ...
        'ResizeFcn', {@graphresize}, ...
        'Tag', 'figSortomatoGraph', ...
        'UserData', char(java.util.UUID.randomUUID()), ...
        'KeyPressFcn', {@keyPress});
    
    %% Add the figure to the base's graph children.
    graphChildren = getappdata(guiSortomato, 'graphChildren');
    graphChildren = [graphChildren; figSortomatoGraph];
    setappdata(guiSortomato, 'graphChildren', graphChildren);
    
    %% Load the cdata struct and set the figure, font and region cycling colors.
    if any(get(guiSortomato, 'Color'))
        sortomatographCData = load('sortomatograph_cdata.mat');
        set(figSortomatoGraph, 'Color', 'w', 'ColorMap', wjet(64))
        bColor = 'w';
        bColorJava = java.awt.Color.white;
        fColor = 'k';

        colorOrder = [
            0 0 0;
            1 0 0;
            0 1 0;
            0 0 1;
            0 1 1; 
            1 0 1;
            1 1 0;
            1 0.5 0
            0.5 0.5 0.5];

    else
        sortomatographCData = load('sortomatographK_cdata.mat');
        set(figSortomatoGraph, 'Color', 'k', 'ColorMap', jetbw(64))
        bColor = 'k';
        bColorJava = java.awt.Color.black;
        fColor = 'w';

        colorOrder = [
            1 1 1;
            1 0 0;
            0 1 0;
            0 0 1;
            0 1 1; 
            1 0 1;
            1 1 0;
            1 0.5 0
            0.5 0.5 0.5];

    end % if
    
    %% Create the figure area GUI elements.
    uicontrol(figSortomatoGraph, ...
        'BackgroundColor', bColor, ...
        'FontSize', 14, ...
        'ForegroundColor', fColor, ...
        'Position', [424 43 16 24], ...
        'String', 'X', ...
        'Style', 'text', ...
        'Tag', 'textX')
    
    uicontrol(figSortomatoGraph, ...
        'BackgroundColor', bColor, ...
        'Callback', {@popupgraphvariablecallback, figSortomatoGraph}, ...
        'FontSize', 12, ...
        'ForegroundColor', fColor, ...
        'Position', [400 45 16 24], ...
        'String', {statStruct.Name}, ...
        'Style', 'popupmenu', ...
        'Tag', 'popupX', ...
        'TooltipString', 'Select a variable for the x axis', ...
        'Value', 1)

    uicontrol(figSortomatoGraph, ...
        'BackgroundColor', bColor, ...
        'FontSize', 14, ...
        'ForegroundColor', fColor, ...
        'Position', [10 424 16 24], ...
        'String', 'Y', ...
        'Style', 'text', ...
        'Tag', 'textY')
    
    uicontrol(figSortomatoGraph, ...
        'BackgroundColor', bColor, ...
        'Callback', {@popupgraphvariablecallback, figSortomatoGraph}, ...
        'FontSize', 12, ...
        'ForegroundColor', fColor, ...
        'Position', [34 426 16 24], ...
        'String', {statStruct.Name}, ...
        'Style', 'popupmenu', ...
        'Tag', 'popupY', ...
        'TooltipString', 'Select a variable for the y axis', ...
        'Value', 1)
    
    uicontrol(figSortomatoGraph, ...
        'BackgroundColor', bColor, ...
        'FontSize', 14, ...
        'ForegroundColor', fColor, ...
        'Position', [60 424 81 24], ...
        'String', 'Regions', ...
        'Style', 'text', ...
        'Tag', 'textRegions')
    
    uicontrol(figSortomatoGraph, ...
        'BackgroundColor', bColor, ...
        'FontSize', 12, ...
        'ForegroundColor', fColor, ...
        'Position', [308 426 108 24], ...
        'String', ' ', ...
        'Style', 'popupmenu', ...
        'Tag', 'popupRegions', ...
        'TooltipString', 'Select a region from the graph', ...
        'Value', 1)
    
    %% Create the axes and axes context menu.
    axesGraph = axes(...
        'Color', 'None', ...
        'ColorOrder', colorOrder, ...
        'FontName', 'Arial', ...
        'FontSize', 11, ...
        'NextPlot', 'Add', ...
        'Parent', figSortomatoGraph, ...
        'Tag', 'axesGraph', ...
        'TickDir', 'Out', ...
        'Units', 'Pixels', ...
        'XColor', fColor, ...
        'YColor', fColor, ...
        'ZColor', fColor);
    set(axesGraph, 'Position', [75 95 300 300])
    
    % Create the conext menu and options.
    axesMenu = uicontextmenu;
    set(axesGraph, 'uicontextmenu', axesMenu)
    
    uimenu(axesMenu, ...
        'Callback', {@graphlinearscale, axesGraph, axesMenu}, ...
        'Checked', 'on', ...
        'Label', 'Linear scaling', ...
        'Tag', 'menuAxesLinearScale')
    
    uimenu(axesMenu, ...
        'Callback', {@graphlogscale, axesGraph, axesMenu}, ...
        'Label', 'Log scaling', ...
        'Tag', 'menuAxesLogScale')
    
    uimenu(axesMenu, ...
        'Callback', {@graphlogxscale, axesGraph, axesMenu}, ...
        'Label', 'Log-x scaling', ...
        'Tag', 'menuAxesLogXScale')
    
    uimenu(axesMenu, ...
        'Callback', {@graphlogyscale, axesGraph, axesMenu}, ...
        'Label', 'Log-y scaling', ...
        'Tag', 'menuAxesLogYScale')
    
    %%  Create a blank plot. 
    % Get the Imaris object's color for visual reference.
    xColor = rgb32bittotriplet(xObject.GetColorRGBA);
    
    % Note: line is faster than scatter, but scatter enables symbol patch manipulation.
    xData = nan(size(statStruct(1).Values));
    yData = nan(size(statStruct(1).Values));
    hScatter = line(...
        'LineStyle', 'none', ...
        'Marker', 'd', ...
        'MarkerEdgeColor', 'none', ...
        'MarkerFaceColor', xColor, ...
        'MarkerSize', 3, ...
        'Parent', axesGraph, ...
        'Tag', 'hScatter', ...
        'XData', xData, ...
        'YData', yData);
    uistack(hScatter, 'bottom')
    
    % Store the plot and data variables.
    setappdata(axesGraph, 'hScatter', hScatter)
    setappdata(axesGraph, 'xData', xData)
    setappdata(axesGraph, 'yData', yData)
    
    %% Initialize default contour settings.
    % Set the default number of contour levels.
    setappdata(axesGraph, 'contourLevels', 64)
    
    % Create a default smoothing kernel.
    contourStrel = strel('disk', 3, 0);
    strelNhood =  getnhood(contourStrel); % strelNhood = contourStrel.getnhood;
    contourKernel = strelNhood/sum(strelNhood(:));
    setappdata(axesGraph, 'contourKernel', contourKernel)
    
    % Store the colormap name.
    setappdata(axesGraph, 'colormapName', 'Jet')
    
    %% Create the toolbar and toolbar buttons.
    toolbarGraph = uitoolbar(figSortomatoGraph, ...
        'Tag', 'toolbarSortomatoGraph');

    % Create the toolbar buttons.
    uipushtool(toolbarGraph, ...
        'BusyAction', 'cancel', ...
        'CData', sortomatographCData.Ellipse, ...
        'ClickedCallback', {@pushregioncreatecallback, figSortomatoGraph}, ...
        'Interruptible', 'off', ...
        'Tag', 'pushEllipse', ...
        'TooltipString', 'Create an ellipse region')
    
    uipushtool(toolbarGraph, ...
        'BusyAction', 'cancel', ...
        'CData', sortomatographCData.Polygon, ...
        'ClickedCallback', {@pushregioncreatecallback, figSortomatoGraph}, ...
        'Interruptible', 'off', ...
        'Tag', 'pushPolygon', ...
        'TooltipString', 'Create a polygon region')
    
    uipushtool(toolbarGraph, ...
        'BusyAction', 'cancel', ...
        'CData', sortomatographCData.Rectangle, ...
        'ClickedCallback', {@pushregioncreatecallback, figSortomatoGraph}, ...
        'Interruptible', 'off', ...
        'Tag', 'pushRectangle', ...
        'TooltipString', 'Create a rectangle region')
    
    uipushtool(toolbarGraph, ...
        'BusyAction', 'cancel', ...
        'CData', sortomatographCData.Freehand, ...
        'ClickedCallback', {@pushregioncreatecallback, figSortomatoGraph}, ...
        'Interruptible', 'off', ...
        'Tag', 'pushFreehand', ...
        'TooltipString', 'Create a freehand region')

    uipushtool(toolbarGraph, ...
        'CData', sortomatographCData.RegionDelete, ...
        'ClickedCallback', {@pushregiondeletecallback, figSortomatoGraph}, ...
        'Separator', 'on', ...
        'Tag', 'pushRegionDelete', ...
        'TooltipString', 'Delete the selected region')
    
    uipushtool(toolbarGraph, ...
        'CData', sortomatographCData.RegionGraph, ...
        'ClickedCallback', {@pushregiongraphcallback, figSortomatoGraph, guiSortomato}, ...
        'Separator', 'on', ...
        'Tag', 'pushRegionGraph', ...
        'TooltipString', 'Graph the objects inside the selected region')
    
    uipushtool(toolbarGraph, ...
        'CData', sortomatographCData.RegionOutsideGraph, ...
        'ClickedCallback', {@pushregiongraphcallback, figSortomatoGraph, guiSortomato}, ...
        'Tag', 'pushRegionOutsideGraph', ...
        'TooltipString', 'Graph the objects outside the selected region')
    
    uipushtool(toolbarGraph, ...
        'CData', sortomatographCData.RegionSort, ...
        'ClickedCallback', {@pushregionsortcallback, figSortomatoGraph, guiSortomato}, ...
        'Tag', 'pushRegionSort', ...
        'TooltipString', 'Transfer the objects inside the selected region into a new Surpass object')
    
    uipushtool(toolbarGraph, ...
        'CData', sortomatographCData.RegionOutsideSort, ...
        'ClickedCallback', {@pushregionsortcallback, figSortomatoGraph, guiSortomato}, ...
        'Tag', 'pushRegionOutsideSort', ...
        'TooltipString', 'Transfer the objects outside the selected region into a new Surpass object')
    
    uitoggletool(toolbarGraph, ...
        'CData', sortomatographCData.DataCursor, ...
        'ClickedCallback', {@toggledatacursorcallback, figSortomatoGraph}, ...
        'Separator', 'on', ...
        'Tag', 'toggleDataCursor', ...
        'TooltipString', 'Activate the data cursor')
    
    uitoggletool(toolbarGraph, ...
        'CData', sortomatographCData.Zoom, ...
        'ClickedCallback', {@togglezoomcallback, figSortomatoGraph}, ...
        'Tag', 'toggleZoom', ...
        'TooltipString', 'Activate zooming')
    
    uitoggletool(toolbarGraph, ...
        'CData', sortomatographCData.Pan, ...
        'ClickedCallback', {@togglepancallback, figSortomatoGraph}, ...
        'Tag', 'togglePan', ...
        'TooltipString', 'Activate panning')
    
    uipushtool(toolbarGraph, ...
        'CData', sortomatographCData.ManualLimits, ...
        'ClickedCallback', {@manuallimits, figSortomatoGraph}, ...
        'Tag', 'toggleManualLimits', ...
        'TooltipString', 'Set automatic or manual axes limits')
    
    uipushtool(toolbarGraph, ...
        'CData', sortomatographCData.AxesSwap, ...
        'ClickedCallback', {@pushaxesswapcallback, figSortomatoGraph}, ...
        'Tag', 'pushAxesSwap', ...
        'TooltipString', 'Swap the x and y axis variables')
    
    toggleContour = uitoggletool(toolbarGraph, ...
        'CData', sortomatographCData.Contour, ...
        'ClickedCallback', {@togglecontourcallback, figSortomatoGraph, axesGraph}, ...
        'Separator', 'on', ...
        'Tag', 'toggleContour', ...
        'TooltipString', 'Switch to a contour plot');
    setappdata(toggleContour, 'toggleContourCData', sortomatographCData.Contour)
    setappdata(toggleContour, 'toggleScatterCData', sortomatographCData.Scatter)
    
    uipushtool(toolbarGraph, ...
        'CData', sortomatographCData.ContourSettings, ...
        'ClickedCallback', '', ...
        'Tag', 'pushContourSettings', ...
        'TooltipString', 'Change contour settings')
    
    uipushtool(toolbarGraph, ...
        'CData', sortomatographCData.GraphExport, ...
        'ClickedCallback', {@pushgraphexportcallback, figSortomatoGraph}, ...
        'Separator', 'on', ...
        'Tag', 'pushGraphExport', ...
        'TooltipString', 'Export the current graph')
    
    uipushtool(toolbarGraph, ...
        'CData', sortomatographCData.GraphDataExport, ...
        'ClickedCallback', {@pushgraphdataexportcallback, figSortomatoGraph}, ...
        'Tag', 'pushGraphDataExport', ...
        'TooltipString', 'Export the current graph data')
    
    %% Set the toobar and button backgrounds.
    % Get the underlying JToolbar component.
    drawnow
    jToolbar = get(get(toolbarGraph, 'JavaContainer'), 'ComponentPeer');
    
    % Set the toolbar background color.
    jToolbar.setBackground(bColorJava);
    jToolbar.getParent.getParent.setBackground(bColorJava);
    
    % Set the toolbar components' background color.
    jtbComponents = jToolbar.getComponents;
    for t = 1:length(jtbComponents)
        jtbComponents(t).setOpaque(false);
        jtbComponents(t).setBackground(bColorJava);
    end % for t
    
    % Set the toolbar more icon to a custom icon that matches the figure color.
    javaImage = im2java(sortomatographCData.MoreToolbar);
    javaIcon = javax.swing.ImageIcon(javaImage);
    jtbComponents(1).setIcon(javaIcon)
    jtbComponents(1).setToolTipText('More tools')
    
    %% Create the region tracking variables.
    setappdata(axesGraph, 'lastRegionColor', 0)
    
    regionStruct = struct();
    setappdata(axesGraph, 'regionStruct', regionStruct)
    setappdata(axesGraph, 'nextRegionTag', [1 1 1 1]) % [Ellipse Polygon Rectangle Freehand]
    setappdata(axesGraph, 'isUserDrawing', 0)
    
    %% Setup the status bar.
    hStatus = statusbar(figSortomatoGraph, '');
    hStatus.CornerGrip.setVisible(false)
    
    hStatus.ProgressBar.setForeground(java.awt.Color.black)
    hStatus.ProgressBar.setString('')
    hStatus.ProgressBar.setStringPainted(true)

    %% Store the XT objects and data associated with the figure.
    xImarisApp = getappdata(guiSortomato, 'xImarisApp');
    setappdata(figSortomatoGraph, 'xImarisApp', xImarisApp)
    setappdata(figSortomatoGraph, 'guiSortomato', guiSortomato)
    setappdata(figSortomatoGraph, 'xObject', xObject)
    setappdata(figSortomatoGraph, 'statStruct', statStruct)
end % sortomatograph


function graphresize(hFigure, eventData)
    % SORTOMATOGRAPHRESIZE Resize the graph
    %
    %
    
    %% Get the figure position.
    figurePos = get(hFigure, 'Position');
    
    % Limit the minimum figure size.
    if figurePos(3) < 281
        figurePos(3) = 281;
        set(hFigure, 'Position', figurePos)
    end % if
    
    if figurePos(4) < 261
        figurePos(2) = figurePos(2) + figurePos(4) - 261;
        figurePos(4) = 261;
        set(hFigure, 'Position', figurePos)
    end % if
    
    %% Fix the x label relative to the lower-right corner.
    textX = findobj(hFigure, 'Tag', 'textX');
    textXPos = get(textX, 'Position');

    % Change the x position.
    textXPos(1) = figurePos(3) - 26;

    % Update the position.
    set(textX, 'Position', textXPos)

    %% Fix the x popup relative to the lower-right corner.
    popupX = findobj(hFigure, 'Tag', 'popupX');
    popupXPos = get(popupX, 'Position');

    % Change the x position.
    popupXPos(1) = figurePos(3) - 50;

    % Update the position.
    set(popupX, 'Position', popupXPos)

    %% Fix the y label relative to the upper-left corner.
    textY = findobj(hFigure, 'Tag', 'textY');
    textYPos = get(textY, 'Position');

    % Change the y position.
    textYPos(2) = figurePos(4) - 46;

    % Update the position.
    set(textY, 'Position', textYPos)

    %% Fix the y popup relative to the upper-left corner.
    popupY = findobj(hFigure, 'Tag', 'popupY');
    popupYPos = get(popupY, 'Position');

    % Change the y position.
    popupYPos(2) = figurePos(4) - 44;

    % Update the position.
    set(popupY, 'Position', popupYPos)

    %% Decide on an offset
    offs = 150;
    
    %% Fix the regions label relative to the upper-left corner.
    textRegions = findobj(hFigure, 'Tag', 'textRegions');
    textRegionsPos = get(textRegions, 'Position');

    % Change the x and y position.
    textRegionsPos(1) = figurePos(3) - 231 - offs;
    textRegionsPos(2) = figurePos(4) - 46;

    % Update the position.
    set(textRegions, 'Position', textRegionsPos)
    
    %% Fix the regions popup relative to the upper-right corner.
    popupRegions = findobj(hFigure, 'Tag', 'popupRegions');
    popupRegionsPos = get(popupRegions, 'Position');

    % Change the x and y positions.
    popupRegionsPos(1) = figurePos(3) - 142 - offs;
    popupRegionsPos(2) = figurePos(4) - 44;
    popupRegionsPos(3) = popupRegionsPos(3) + offs;

    % Update the position.
    set(popupRegions, 'Position', popupRegionsPos)

    %% Fix the axes relative to the lower-left and upper-right corners.
    axesGraph = findobj(hFigure, 'Tag', 'axesGraph');
    axesPos = get(axesGraph, 'Position');

    % Change the width and height to pin the upper-right corner relative to the
    % window.
    axesPos(3) = figurePos(3) - 150;
    axesPos(4) = figurePos(4) - 170;

    % Update the position.
    set(axesGraph, 'Position', axesPos)    
end % graphresize


function graphclose(figSortomatoGraph, eventData, guiSortomato)
    %
    %
    %

    %% Close the limits window if it exists.
    guiLimits = getappdata(figSortomatoGraph, 'guiLimits');
    if ishandle(guiLimits)
        delete(guiLimits)
    end % if
    
    %% Close the contour settings window if it exists.
    guiContourSettings = getappdata(figSortomatoGraph, 'guiContourSettings');
    if ishandle(guiContourSettings)
        delete(guiContourSettings)
    end % if
    
    %% Remove the graph GUI handle from the base GUI appdata.
    % Get the graph GUI handles list from the base GUI.
    graphChildren = getappdata(guiSortomato, 'graphChildren');

    % Remove the current graph from the list.
    graphChildren(graphChildren == figSortomatoGraph) = [];

    % Replace the appdata.
    setappdata(guiSortomato, 'graphChildren', graphChildren)
        
    % Now delete the GUI.
    delete(figSortomatoGraph);    
end % graphclose

function keyPress(src, e)     
    containsShift = @(s) ~isempty(regexp(s,'shift'));
    shifted = any(cellfun(containsShift,e.Modifier));
    
    switch e.Key
        case 'e'
            editRegionName(src,e);
        case 'h'
            showLabels(src,shifted);
        case 'c'
            clipb = getSaveStruct(src,e,shifted);
            setappdata(0,'sortomato_clipboard',clipb);
        case 's'
            clipb = getSaveStruct(src,e,true);
            xIA=getappdata(src,'xImarisApp');
            filename = char(xIA.GetCurrentFileName);
            uisave({'clipb'},[filename(1:end-3) 'mat']);
        case 'p'
            clipb = getappdata(0,'sortomato_clipboard');
            setSaveStruct(src,e,clipb,shifted);             
        case 'o'
            [FileName,PathName] = uigetfile('settings.mat');
            S = load(fullfile(PathName,FileName),'clipb');
            clipb = S.clipb
             
            setSaveStruct(src,e,clipb,true);
    end
end % keyPress

function showLabels(src,isshow)
    axesGraph = findobj(src, 'Tag', 'axesGraph');

    regions = getappdata(axesGraph, 'regionStruct');

    if isshow
        vis = 'on';
    else
        vis = 'off';
    end
    
    for rtyp = {'Rect' 'Ellipse' 'Poly' 'Freehand'}
        mrtyp = rtyp{1};
        if ~isfield(regions,mrtyp)
            continue
        end
        oregs = regions.(mrtyp);
        for i=1:length(oregs)
            set(oregs(i).Label,'Visible',vis);
        end
    end
end

function editRegionName(src,e)
    axesGraph = findobj(src, 'Tag', 'axesGraph');
    popupRegions = findobj(src, 'Tag', 'popupRegions');
    curRegion = get(popupRegions, 'Value');
    regionNames = get(popupRegions, 'String');
    curname = regionNames{curRegion};
    
    rtype = curname(1:4);
    
    newname = inputdlg('Enter new name for current region','Edit name',1,{curname});
    
    if length(newname)<1
        return
    end
    
    newname = newname{1};
    
    if length(newname)<4 || ~strcmp(newname(1:4),rtype)
        newname = [rtype '-' newname];
    end
    
    regions = getappdata(axesGraph,'regionStruct');
    switch rtype
        case 'Elli'
            i=strcmp({regions.Ellipse.Name},curname);
            reg = regions.Ellipse(i);
        case 'Rect'
            i=strcmp({regions.Rect.Name},curname);
            reg = regions.Rect(i);
        case 'Poly'
            i=strcmp({regions.Poly.Name},curname);
            reg = regions.Poly(i);
        otherwise
            i=strcmp({regions.Freehand.Name},curname);
            reg = regions.Freehand(i);
    end
    
    regionNames{curRegion}=newname;
    set(reg.Label,'String',newname);
    reg.Name=newname;
    %reg.setLabel();
    set(popupRegions,'String',regionNames);
    
    setappdata(axesGraph,'regionStruct',regions);
end 

function setSaveStruct(src,e,clipb,shifted)
    axesGraph = findobj(src, 'Tag', 'axesGraph');
    
    set(findobj(src, 'Tag', 'popupX'),'Value',clipb.xvar);
    popupgraphvariablecallback(findobj(src, 'Tag', 'popupX'),[],src);
    set(axesGraph,'XLim',clipb.xlim);
    set(findobj(src, 'Tag', 'popupY'),'Value',clipb.yvar);
    popupgraphvariablecallback(findobj(src, 'Tag', 'popupY'),[],src);
    set(axesGraph,'YLim',clipb.ylim);

    regs = getappdata(axesGraph, 'regionStruct');
    if shifted
     popupRegions = findobj(src, 'Tag', 'popupRegions');

     typs = fieldnames(clipb.regions)';
     
     for typ = typs;
         mtyp = typ{1};
         
         cregs = clipb.regions.(mtyp);
         if ~isfield(cregs,'position')
             continue
         end
         for i=1:numel(cregs)
             switch mtyp
                 case 'Rect'
                     s = sortomatorect(axesGraph,cregs(i).position);
                     s.Name = cregs(i).label;
                     s.setLabel(); %uicontrol(src,'Style','text','String',));
                     if isfield(regs,'Rect')
                         regs.Rect(end+1) = s;
                     else
                         regs.Rect = s;
                     end
                 case 'Ellipse'
                     s = sortomatoellipse(axesGraph,cregs(i).position);
                     s.Name = cregs(i).label;
                     s.setLabel(); %uicontrol(src,'Style','text','String',));
                     if isfield(regs,'Ellipse')
                         regs.Ellipse(end+1) = s;
                     else
                         regs.Ellipse = s;
                     end
                 case 'Poly'
                     s = sortomatopoly(axesGraph,cregs(i).position);
                     s.Name = cregs(i).label;
                     s.setLabel(); %uicontrol(src,'Style','text','String',));
                     if isfield(regs,'Poly')
                         regs.Poly(end+1) = s;
                     else
                         regs.Poly = s;
                     end
                 case 'Freehand'
                     warning('I cannot load or paste freehands.... :(');
                     %s = sortomatofreehand(axesGraph,cregs(i).position);
                     %s.Name = cregs(i).label;
                     %s.setLabel(); %uicontrol(src,'Style','text','String',));
                     %if isfield(regs,'Freehand')
                     %    regs.Freehand(end+1) = s;
                     %else
                     %    regs.Freehand = s;
                     %end
             end

             popupString = get(popupRegions, 'String');
             if strcmp(popupString, ' ')
                popupString = {s.Name};
             else
                popupString = [get(popupRegions, 'String'); {s.Name}];
             end % if

             set(popupRegions, ...
                    'String', popupString, ...
                    'Value', length(popupString))                     
         end
     end
     setappdata(axesGraph, 'regionStruct', regs)
    end
end

function clipb = getSaveStruct(src,e,shifted)
    axesGraph = findobj(src, 'Tag', 'axesGraph');
    clipb = struct;
    clipb.xvar = get(findobj(src, 'Tag', 'popupX'),'Value');
    clipb.xlim = get(axesGraph,'XLim');
    clipb.yvar = get(findobj(src, 'Tag', 'popupY'),'Value');
    clipb.ylim = get(axesGraph,'YLim');
    clipb.regions = struct;
    
    if shifted
     regions = getappdata(axesGraph,'regionStruct');
     for rtyp = {'Rect' 'Ellipse' 'Poly'} % 'Freehand' currently not supported
        mrtyp = rtyp{1};
        if ~isfield(regions,mrtyp)
            continue
        end
        oregs = regions.(mrtyp);
        regs = struct;
        for i=1:length(oregs)
             regs(i).position = getPosition(oregs(i));
             regs(i).label = get(oregs(i).Label,'String');     
        end
        clipb.regions.(mrtyp) = regs;
     end
    end
    
    % Save the objects name
    on = get(gcf,'Name');
    colon=find(on==':',1,'last');
    clipb.objectsName = on(1:colon-1);
end
