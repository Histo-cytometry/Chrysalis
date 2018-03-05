function guiContourSettings = contoursettings(hObject, eventData, figSortomatoGraph, axesGraph)
    % CONTOURSETTINGS Change Sortomato contour plot settings
    %   SORTOMATOCONTOURSETTINGS creates a GUI to adjust contour plot
    %   settings in a Sortomato graph.
    
    %% Check for a contour settings figure.
    guiContourSettings = getappdata(figSortomatoGraph, 'guiContourSettings');
    if ~isempty(guiContourSettings)
        figure(guiContourSettings)
        return
    end % if
    
    %% Set the figure and font colors.
    if all(get(figSortomatoGraph, 'Color') == [0 0 0])
        bColor = 'k';
        bColorJava = java.awt.Color.black;
        fColor = 'w';
        fColorJava = java.awt.Color.white;

    else
        bColor = 'w';
        bColorJava = java.awt.Color.white;
        fColor = 'k';
        fColorJava = java.awt.Color.black;
        
    end % if
    
    %% Create the contour settings figure.
    % Create the figure.
    graphPosition = get(figSortomatoGraph, 'Position');
    
    guiWidth = 230;
    guiHeight = 157;
    guiPosition = [graphPosition(1) + 0.5*graphPosition(3) - guiWidth/2, ...
        graphPosition(2) + 0.5*graphPosition(4) - guiHeight/2, guiWidth, guiHeight];
    
    guiContourSettings = figure(...
        'CloseRequestFcn', {@closerequestfcn, figSortomatoGraph}, ...
        'Color', bColor, ...
        'MenuBar', 'None', ...
        'Name', 'Contour settings', ...
        'NumberTitle', 'off', ...
        'Position', guiPosition, ...
        'Resize', 'off', ...
        'Tag', 'guiContourSettings');
        
    %% Get the contour settings from the graph.
    contourLevels = getappdata(axesGraph, 'contourLevels');
    contourSmoothing = floor(size(getappdata(axesGraph, 'contourKernel'), 1)/2);
    colormapName = getappdata(axesGraph, 'colormapName');
    
    %% Create the GUI elements.
    % Create the colormap popup menu.
    uicontrol(...
        'Background', bColor, ...
        'FontSize', 12, ...
        'Foreground', fColor', ...
        'HorizontalAlign', 'Left', ...
        'Parent', guiContourSettings, ...
        'Position', [10 16 98 24], ...
        'String', 'Colormap', ...
        'Style', 'Text', ...
        'Tag', 'textLevels');
    
    colorMapList = {'Bone', 'Gray', 'Hot', 'Pink', 'Jet'};
    colormapIdx = find(strcmp(colorMapList, colormapName));
    
    popupColorMap = uicomponent(...
        'Background', bColor, ...
        'Callback', {@popupcolormapcallback, axesGraph, bColor}, ...
        'FontSize', 12, ...
        'Foreground', fColor, ...
        'Parent', guiContourSettings, ...
        'Position', [131 20 90 24], ...
        'Style', 'popupmenu', ...
        'String', colorMapList, ...
        'Tag', 'popupColorMap', ...
        'TooltipString', 'Select a colormap for the contour plot', ...
        'Value', colormapIdx);
    
    % Create the smoothing slider.
    uicontrol(...
        'Background', bColor, ...
        'FontSize', 12, ...
        'Foreground', fColor', ...
        'HorizontalAlign', 'Left', ...
        'Parent', guiContourSettings, ...
        'Position', [10 68 100 24], ...
        'String', 'Smoothing', ...
        'Style', 'Text', ...
        'Tag', 'textLevels');
    
    uicomponent(...
        'Background', bColorJava, ...
        'Foreground', fColorJava, ...
        'KeyReleasedCallback', {@slidersmoothingcallback, axesGraph}, ...
        'Minimum', 0, ...
        'Maximum', 10, ...
        'MouseReleasedCallback', {@slidersmoothingcallback, axesGraph}, ...
        'Name', 'sliderSmoothing', ...
        'Parent', guiContourSettings, ...
        'Position', [126, 70, 100, 24], ...
        'Style', 'javax.swing.jslider', ...
        'ToolTipText', num2str(contourSmoothing, '%u'), ...
        'Value', contourSmoothing);
    
    % Create the contour level slider.
    uicontrol(...
        'Background', bColor, ...
        'FontSize', 12, ...
        'Foreground', fColor', ...
        'HorizontalAlign', 'Left', ...
        'Parent', guiContourSettings, ...
        'Position', [10 118 100 24], ...
        'String', 'Contour levels', ...
        'Style', 'Text', ...
        'Tag', 'textLevels');
    
    uicomponent(...
        'Background', bColorJava, ...
        'Foreground', fColorJava, ...
        'KeyReleasedCallback', {@sliderlevelscallback, axesGraph, popupColorMap, bColor}, ...
        'Minimum', 4, ...
        'Maximum', 128, ...
        'MouseReleasedCallback', {@sliderlevelscallback, axesGraph, popupColorMap, bColor}, ...
        'Name', 'sliderContour', ...
        'Parent', guiContourSettings, ...
        'Position', [126, 120, 100, 24], ...
        'Style', 'javax.swing.jslider', ...
        'ToolTipText', num2str(contourLevels, '%u'), ...
        'Value', contourLevels);
    
    %% Store the settings GUI handle.
    setappdata(figSortomatoGraph, 'guiContourSettings', guiContourSettings)
end % contoursettings


function sliderlevelscallback(sliderContour, eventData, axesGraph, popupColorMap, bColor)
    % CONTOURSLIDERCALLBACK Changes the Sortomato contour plot levels
    %   
    %   
    
    %% Get the updated number of contour levels to use.
    contourLevels = round(get(sliderContour, 'Value'));
    set(sliderContour, 'ToolTipText', num2str(contourLevels, '%u'))
    
    % Update the stored contour levels.
    setappdata(axesGraph, 'contourLevels', contourLevels)
    
    %% Delete the previous contour.
    hContour = getappdata(axesGraph, 'hContour');
    delete(hContour)

    %% Get the plot data.
    xData = getappdata(axesGraph, 'xData');
    yData = getappdata(axesGraph, 'yData');
            
    %% Generate a histogram of the data.
    % Create the raw histogram.
    [xyHist, xyLocs] = hist3([yData, xData], [contourLevels contourLevels]);

    % Get the smoothing kernel.
    contourKernel = getappdata(axesGraph, 'contourKernel');

    % Smooth the histogram.
    if ~isscalar(contourKernel)
        xyHistSmooth = filter2(contourKernel, padarray(xyHist, [1 1]));
        xyHistSmooth = xyHistSmooth(2:end - 1, 2:end - 1);
        
    else
        xyHistSmooth = xyHist;
        
    end % if

    %% Create the contour plot.
    [cMatrix, hContour] = contourf(axesGraph, xyLocs{2}, xyLocs{1}, xyHistSmooth, ...
        contourLevels, 'LineColor', 'None');
    set(hContour, 'HitTest', 'off')
    uistack(hContour, 'bottom')
    
    set(axesGraph, 'XLimMode', 'Auto', 'YLimMode', 'Auto')

    % Store the contour handle and information.
    setappdata(axesGraph, 'hContour', hContour);
    setappdata(axesGraph, 'contourLevels', contourLevels)
    
    %% Get the popup selection.
    colorMapList = get(popupColorMap, 'String');
    colorMapIdx = get(popupColorMap, 'Value');
        
    %% Update the colormap for the new number of contour levels.
    if strcmp(bColor, 'k')
        switch lower(colorMapList{colorMapIdx})

            case 'bone'
                colormap(axesGraph, bone(contourLevels))
                setappdata(axesGraph, 'colormapName', 'Bone')

            case 'gray'
                colormap(axesGraph, gray(contourLevels))
                setappdata(axesGraph, 'colormapName', 'Gray')

            case 'hot'
                colormap(axesGraph, hot(contourLevels))
                setappdata(axesGraph, 'colormapName', 'Hot')

            case 'pink'
                colormap(axesGraph, pink(contourLevels))
                setappdata(axesGraph, 'colormapName', 'Pink')

            case 'jet'
                colormap(axesGraph, jetbw(contourLevels))
                setappdata(axesGraph, 'colormapName', 'Jet')

            otherwise
                colormap(axesGraph, bwjet(contourLevels))
                setappdata(axesGraph, 'colormapName', 'Jet')

        end % switch
        
    else
        switch lower(colorMapList{colorMapIdx})

            case 'bone'
                colormap(axesGraph, flipud(bone(contourLevels)))
                setappdata(axesGraph, 'colormapName', 'Bone')

            case 'gray'
                colormap(axesGraph, flipud(gray(contourLevels)))
                setappdata(axesGraph, 'colormapName', 'Gray')

            case 'hot'
                colormap(axesGraph, flipud(hot(contourLevels)))
                setappdata(axesGraph, 'colormapName', 'Hot')

            case 'pink'
                colormap(axesGraph, flipud(pink(contourLevels)))
                setappdata(axesGraph, 'colormapName', 'Pink')

            case 'jet'
                colormap(axesGraph, wjet(contourLevels))
                setappdata(axesGraph, 'colormapName', 'Jet')

            otherwise
                colormap(axesGraph, wjet(contourLevels))
                setappdata(axesGraph, 'colormapName', 'Jet')

        end % switch
        
    end % if
end % sliderlevelscallback


function slidersmoothingcallback(sliderSmoothing, eventData, axesGraph)
    % SLIDERSMOOTHINGCALLBACK Changes the Sortomato contour smoothing
    %   
    %   
    
    %% Create the new smoothing kernel.
    % Get the updated smoothing radius to use.
    contourSmoothing = round(get(sliderSmoothing, 'Value'));
    set(sliderSmoothing, 'ToolTipText', num2str(contourSmoothing, '%u'))
    
    % Update the smoothing kernel.
    contourStrel = strel('disk', contourSmoothing, 0);
    strelNhood =  getnhood(contourStrel); % strelNhood = contourStrel.getnhood;
    contourKernel = strelNhood/sum(strelNhood(:));

    % Update the stored kernel.
    setappdata(axesGraph, 'contourKernel', contourKernel)
    
    %% Delete the previous contour.
    hContour = getappdata(axesGraph, 'hContour');
    delete(hContour)

    %% Get the plot data.
    xData = getappdata(axesGraph, 'xData');
    yData = getappdata(axesGraph, 'yData');
            
    %% Generate a histogram of the data.
    % Create the raw histogram.
    contourLevels = getappdata(axesGraph, 'contourLevels');
    [xyHist, xyLocs] = hist3([yData, xData], [contourLevels contourLevels]);

    % Smooth the histogram.
    if ~isscalar(contourKernel)
        xyHistSmooth = filter2(contourKernel, padarray(xyHist, [1 1]));
        xyHistSmooth = xyHistSmooth(2:end - 1, 2:end - 1);
        
    else
        xyHistSmooth = xyHist;
        
    end % if

    %% Create the contour plot.
    [cMatrix, hContour] = contourf(axesGraph, xyLocs{2}, xyLocs{1}, xyHistSmooth, ...
        contourLevels, 'LineColor', 'None');
    set(hContour, 'HitTest', 'off')
    uistack(hContour, 'bottom')

    set(axesGraph, 'XLimMode', 'Auto', 'YLimMode', 'Auto')
    
    % Store the contour handle and information.
    setappdata(axesGraph, 'hContour', hContour);
    setappdata(axesGraph, 'contourSmoothing', contourSmoothing)
end % slidersmoothingcallback


function popupcolormapcallback(popupColorMap, eventData, axesGraph, bColor)
    % POPUPCOLORMAPCALLBACK Change the Sortomato graph colormap
    %   
    %   
    
    %% Get the popup selection.
    colorMapList = get(popupColorMap, 'String');
    colorMapIdx = get(popupColorMap, 'Value');
        
    %% Get the number of contour levels for the color map size.
    contourLevels = getappdata(axesGraph, 'contourLevels');
    
    %% Apply the color map to the axes.
    if strcmp(bColor, 'k')
        switch lower(colorMapList{colorMapIdx})

            case 'bone'
                colormap(axesGraph, bone(contourLevels))
                setappdata(axesGraph, 'colormapName', 'Bone')

            case 'gray'
                colormap(axesGraph, gray(contourLevels))
                setappdata(axesGraph, 'colormapName', 'Gray')

            case 'hot'
                colormap(axesGraph, hot(contourLevels))
                setappdata(axesGraph, 'colormapName', 'Hot')

            case 'pink'
                colormap(axesGraph, pink(contourLevels))
                setappdata(axesGraph, 'colormapName', 'Pink')

            case 'jet'
                colormap(axesGraph, jetbw(contourLevels))
                setappdata(axesGraph, 'colormapName', 'Jet')

            otherwise
                colormap(axesGraph, bwjet(contourLevels))
                setappdata(axesGraph, 'colormapName', 'Jet')

        end % switch
        
    else
        switch lower(colorMapList{colorMapIdx})

            case 'bone'
                colormap(axesGraph, flipud(bone(contourLevels)))
                setappdata(axesGraph, 'colormapName', 'Bone')

            case 'gray'
                colormap(axesGraph, flipud(gray(contourLevels)))
                setappdata(axesGraph, 'colormapName', 'Gray')

            case 'hot'
                colormap(axesGraph, flipud(hot(contourLevels)))
                setappdata(axesGraph, 'colormapName', 'Hot')

            case 'pink'
                colormap(axesGraph, flipud(pink(contourLevels)))
                setappdata(axesGraph, 'colormapName', 'Pink')

            case 'jet'
                colormap(axesGraph, wjet(contourLevels))
                setappdata(axesGraph, 'colormapName', 'Jet')

            otherwise
                colormap(axesGraph, wjet(contourLevels))
                setappdata(axesGraph, 'colormapName', 'Jet')

        end % switch
        
    end % if
end % popupcolormapcallback


function closerequestfcn(guiContourSettings, eventData, figSortomatoGraph)
    % Close sortomato sub-GUIs
    %
    %
    
    %% Remove the GUI handle appdata and delete.
    rmappdata(figSortomatoGraph, 'guiContourSettings')
    delete(guiContourSettings);
end % closerequestfcn