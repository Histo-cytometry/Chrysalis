classdef sortomatopoly < impoly & dynamicprops
    %   SORTOMATOPOLY An impoly subclass with a label option
    %
    %   Syntax
    %   ------
    %   hPoly = sortomatopoly
    %   hPoly = sortomatopoly(hAxes)
    %   hPoly = sortomatopoly(hAxes, position)
    %   hPoly = sortomatopoly(...,param1, val1, ...)
    %
    %   Description
    %   -----------
    %   hPoly = sortomatopoly interactively creates a polygon ROI on the
    %   current axes.
    %   
    %   hPoly = sortomatopoly(hAxes) interactively creates an polygon ROI on the
    %   axes specified by the handle hAxes.
    %
    %   hPoly = sortomatopoly(hAxes, position) creates a draggable, resizable
    %   polygon ROI on the axes specified by the handle hAxes at the
    %   location specified by position, an n-by-2 array specifying the
    %   initial position of the vertices of the polygon
    %
    %   hPoly = sortomatopoly(...,param1, val1, ...) specifies additional
    %   parameter value pairs that control the poly. See impoly for
    %   valid Parmater and Value arguments.
    %
    %   Because sortomatopoly is a subclass for impoly, object creation
    %   syntax is identical to impoly. Type help impoly for more
    %   information.
    %
    %   ©2010-2013, P. Beemiller. Licensed under a Creative Commmons Attribution
    %   license. Please see: http://creativecommons.org/licenses/by/3.0/
    %
    
    properties
        
        Label
        LabelsPositionCallback
        CountLabel
        Name
        
    end % properties
    
    methods
        
        function obj = sortomatopoly(varargin)
            % Constructor function
            %
            %

            obj = obj@impoly(varargin{:});
            
            if ~isequal(size(obj), [0 0])
                % Find the object's context menu.
                roiPatch = findobj(obj, 'Type', 'Patch');
                contextMenu = get(roiPatch, 'UIContextMenu');
                
                % Create menu items to graph the objects inside/outside the
                % region.
                menuGraph = uimenu(contextMenu, ...
                    'Checked', 'off', ...
                    'Label', 'Graph objects', ...
                    'Tag', 'menuGraph');
                
                % Graph inside menu object.
                menuRegionGraph = uimenu(menuGraph, ...
                    'Checked', 'off', ...
                    'Label', 'Inside region', ...
                    'Tag', 'menuRegionGraph');
                set(menuRegionGraph, ...
                    'Callback', @(varargin)...
                    graphRegionObjects(obj, menuRegionGraph))
                
                % Graph outside menu object.
                menuRegionOutsideGraph = uimenu(menuGraph, ...
                    'Checked', 'off', ...
                    'Label', 'Outside region', ...
                    'Tag', 'menuRegionOutsideGraph');
                set(menuRegionOutsideGraph, ...
                    'Callback', @(varargin)...
                    graphRegionObjects(obj, menuRegionOutsideGraph))

                % Create menu items to sort the objects inside/outside the
                % region.
                menuSort = uimenu(contextMenu, ...
                    'Checked', 'off', ...
                    'Label', 'Sort objects', ...
                    'Tag', 'menuSort');
                
                % Sort inside menu object.
                menuRegionSort = uimenu(menuSort, ...
                    'Checked', 'off', ...
                    'Label', 'Inside region', ...
                    'Tag', 'menuRegionSort');
                set(menuRegionSort, ...
                    'Callback', @(varargin)...
                    sortRegionObjects(obj, menuRegionSort))
                
                % Sort outside menu object.
                menuRegionOutsideSort = uimenu(menuSort, ...
                    'Checked', 'off', ...
                    'Label', 'Outside region', ...
                    'Tag', 'menuRegionOutsideSort');
                set(menuRegionOutsideSort, ...
                    'Callback', @(varargin)...
                    sortRegionObjects(obj, menuRegionOutsideSort))
                
                % Create a menu item to apply the region color to data points
                % inside the region.
                uimenu(contextMenu, ...
                    'Callback', @(varargin)setDataColor(obj), ...
                    'Checked', 'off', ...
                    'Label', 'Set Data Color', ...
                    'Tag', 'menuSetDataColor');
                
                % Create a menu item to select the Imaris objects inside the
                % region.
                uimenu(contextMenu, ...
                    'Callback', @(varargin)selectImarisObjects(obj), ...
                    'Checked', 'off', ...
                    'Label', 'Select Imaris objects', ...
                    'Tag', 'menuSelectImarisObjects');
                
                % Create a menu item to delete the region.
                uimenu(contextMenu, ...
                    'Callback', @(varargin)deleteSortomatoRgn(obj), ...
                    'Checked', 'off', ...
                    'Label', 'Delete', ...
                    'Tag', 'menuDelete');
                
                % Update the 'Set Color' menu item callbacks with new color
                % choices.
                setColorMenu = findobj(contextMenu, 'Label', 'Set Color');
                setColorMenuItems = get(setColorMenu, 'Children');

                % Check for a black background. If the effective blackground is
                % black, swap out the black color option for white.
                roiAxes = get(obj, 'Parent');
                roiAxesColor = get(roiAxes, 'Color');
                roiFigureColor = get(get(roiAxes, 'Parent'), 'Color');
                if ischar(roiAxesColor)
                    isBlackBkgd = all(roiFigureColor == [0 0 0]);

                else
                    isBlackBkgd = all(roiAxesColor == [0 0 0]);

                end % if

                if isBlackBkgd
                    colorChoices = [
                        1 1 1; 
                        1 0 0; 
                        0 1 0; 
                        0 0 1;
                        0 1 1; 
                        1 0 1;
                        1 1 0;
                        1 0.5 0
                        0.5 0.5 0.5];

                    colorChoiceLabels = {
                        'White';
                        'Red';
                        'Green';
                        'Blue';
                        'Cyan';
                        'Magenta';
                        'Yellow';
                        'Orange';
                        'Gray'};

                else
                    colorChoices = [
                        0 0 0; 
                        1 0 0; 
                        0 1 0; 
                        0 0 1;
                        0 1 1; 
                        1 0 1;
                        1 1 0;
                        1 0.5 0
                        0.5 0.5 0.5];

                    colorChoiceLabels = {
                        'Black';
                        'Red';
                        'Green';
                        'Blue';
                        'Cyan';
                        'Magenta';
                        'Yellow';
                        'Orange';
                        'Gray'};

                end % if

                % Update the color menu item callbacks.
                for m = 1:length(setColorMenuItems)
                     set(setColorMenuItems(m), ...
                         'Callback', @(varargin)setColor(obj, colorChoices(m, :)), ...
                         'Checked', 'off', ...
                         'Label', colorChoiceLabels{m})
                end % for m
            end % if
        end % sortomatopoly
        
        function updateLabels(obj,~)
            objPos = obj.getPosition;
            rgnCenter = mean(objPos);
            rgnURCorner = [mean(objPos(:,1)) max(objPos(:,2))*1.1];

            [Nin, Nout] = obj.count;
            percIn = Nin/(Nin+Nout) * 100;            

            set(obj.Label, 'Position', rgnCenter);
            set(obj.CountLabel, 'Position', rgnURCorner);
            set(obj.CountLabel, 'String', sprintf('%.2f %%',percIn));
        end
        
        function delete(obj)
            % delete sortomatopoly subclass destructor function
            %
            %
            
            if ishandle(obj.Label)
                delete(obj.Label)
            end % if
            if ishandle(obj.CountLabel)
                delete(obj.CountLabel)
            end % if
        end % delete

        function deleteLabel(obj)
            % deleteLabel Delete the label text object
            %
            %
            
            removeNewPositionCallback(obj, obj.LabelsPositionCallback)
            if ishandle(obj.Label)
                delete(obj.Label)
            end % if
            if ishandle(obj.CountLabel)
                delete(obj.CountLabel)
            end % if
        end % deleteLabel

        function deleteSortomatoRgn(obj)
            % delete the polygon region from the Sortomato graph
            %
            %
            
            %% Call the delete function.
            axesGraph = get(obj, 'Parent');
            figSortomatoGraph = get(axesGraph, 'Parent');
            pushregiondeletecallback([], [], figSortomatoGraph, obj.Name)
        end % deleteSortomatoRgn
        
        function graphRegionObjects(obj, menuObject)
            % graphRegionObjects Create a new graph of objects in the region
            %
            %
            
            %% Gather the inputs for the graph function.
            axesGraph = get(obj, 'Parent');
            figSortomatoGraph = get(axesGraph, 'Parent');
            guiSortomato = getappdata(figSortomatoGraph, 'guiSortomato');
            
            %% Call the graph function.
            pushregiongraphcallback(menuObject, [], figSortomatoGraph, guiSortomato, obj.Name)
        end % graphRegionObjects

        function selectImarisObjects(obj)
            % Select the objects that fall in the region
            %
            %
            
            %% Get the region's vertices.
            rgnVertices = obj.getPosition;
            
            %% Find the data points inside the region.
            axesGraph = get(obj, 'Parent');
            
            xData = getappdata(axesGraph, 'xData');
            yData = getappdata(axesGraph, 'yData');
                                    
            inPlotIdxs = inpolygon(xData, yData, ...
                rgnVertices(:, 1), rgnVertices(:, 2));
            
            %% Find the index in the stat struct for the y axes selection.
            figSortomatoGraph = get(axesGraph, 'Parent');
            popupY = findobj(figSortomatoGraph, 'Tag', 'popupY');
            statIdx = get(popupY, 'Value');

            %% Get the spot/track IDs that correspond to the graphed points.
            % These need to get converted to double for use as inputs to the Surfaces
            % Get methods.
            statStruct = getappdata(figSortomatoGraph, 'statStruct');
            inIDs = double(statStruct(statIdx).Ids(inPlotIdxs));

            %% Get the Imaris object.
            figSortomatoGraph = get(axesGraph, 'Parent');
            guiSortomato = getappdata(figSortomatoGraph, 'guiSortomato');
            
            popupObjects = findobj(guiSortomato, 'Tag', 'popupObjects');
            xObject = getappdata(popupObjects, 'xObject');
            xObject.SetSelectedIndices(inIDs)
        end % selectImarisObjects
        
        function setColor(obj, c)
            % setColor  Set color used to draw ROI object
            %
            %   setColor(h,new_color) sets the color used to draw the ROI
            %   object h. new_color can be a three-element vector
            %   specifying an RGB triplet, or a text string specifying the
            %   long or short names of a predefined color, such as 'white'
            %   or 'w'.
            
            obj.api.setColor(c);
            
            if ishandle(obj.Label)
                set(obj.Label, 'Color', c)
            end % if
            if ishandle(obj.CountLabel)
                set(obj.CountLabel, 'Color', c)
            end % if
        end % setColor
                
        function setDataColor(obj)
            % Apply region color to data markers inside the region
            %
            %
            
            %% Get the region's vertices.
            rgnVertices = obj.getPosition;
            
            %% Get the plot objects and xy data.
            axesGraph = get(obj, 'Parent');
            
            hScatter = getappdata(axesGraph, 'hScatter');
            xData = getappdata(axesGraph, 'xData');
            yData = getappdata(axesGraph, 'yData');
                                    
            %% Find the data points inside the region.
            rgnColorMask = inpolygon(xData, yData, ...
                rgnVertices(:, 1), rgnVertices(:, 2));
            
            %% Update the line plot and create a second line plot for the colored dots.
            % Get the Imaris object's color. Use it for the non-masked
            % data points.
            figSortomatoGraph = get(axesGraph, 'Parent');
            xObject = getappdata(figSortomatoGraph, 'xObject');
            xColor = rgb32bittotriplet(xObject.GetColorRGBA);
            
            set(hScatter(1), ...
                'MarkerFaceColor', xColor, ...
                'XData', xData(~rgnColorMask), ...
                'YData', yData(~rgnColorMask))
            
            delete(findobj(axesGraph, 'Tag', 'hScatter2'))
            hScatter(2) = line(...
                'LineStyle', 'none', ...
                'Marker', 'd', ...
                'MarkerEdgeColor', 'none', ...
                'MarkerFaceColor', obj.getColor, ...
                'MarkerSize', 3, ...
                'Parent', axesGraph, ...
                'Tag', 'hScatter2', ...
                'XData', xData(rgnColorMask), ...
                'YData', yData(rgnColorMask));
            uistack(hScatter, 'bottom')
            
            %% Store the region color mask and scatter handle array.
            setappdata(axesGraph, 'rgnColorMask', rgnColorMask)
            setappdata(axesGraph, 'hScatter', hScatter);
        end % setDataColor
        
        function setLabel(obj)
            % setLabel Set a text label centered on the region
            %
            %

            if ~isempty(obj.Name)
                % Get the polygons's center. For a polygon imroi, the
                % getPosition method returns a list of vertices. The center of
                % the region will be the mean of the vertices.
                rgnCenter = mean(obj.getPosition);

                % Add the text object.
                obj.Label = text(rgnCenter(1), rgnCenter(2), obj.Name, ...
                    'HorizontalAlignment', 'Center', ...
                    'VerticalAlignment', 'Middle', ...
                    'Color', obj.getColor);              
            end % if
            objPos = obj.getPosition;
            rgnURCorner = [mean(objPos(:,1)) max(objPos(:,2))*1.1];

            [Nin, Nout] = obj.count;
            percIn = Nin/(Nin+Nout) * 100;
            
            % Add the text object.
            obj.CountLabel = text(rgnURCorner(1), rgnURCorner(2), sprintf('%.2f %%',percIn), ...
                'Color', obj.getColor, ...
                'HorizontalAlignment', 'Left', ...
                'VerticalAlignment', 'Middle', ...
                'FontSize', 16);

            % Add a position callback to keep the text label centered.
            obj.LabelsPositionCallback = obj.addNewPositionCallback(@(pos) obj.updateLabels(pos));
        end % setLabel
        
        function [Nin Nout] = count(obj) 
            axesGraph = get(obj, 'Parent');
            
            xData = getappdata(axesGraph, 'xData');
            yData = getappdata(axesGraph, 'yData');
                                    
            rgnVertices = obj.getPosition;
            
            %% Find the data points inside the region.
            rgnMask = inpolygon(xData, yData, ...
                rgnVertices(:, 1), rgnVertices(:, 2));
            
            Nin = sum(rgnMask);
            Nout = sum(~rgnMask);
        end
    
        function sortRegionObjects(obj, menuObject)
            % sortRegionObjects sort objects into a new Surpass object
            %
            %
            
            %% Gather the inputs for the graph function.
            axesGraph = get(obj, 'Parent');
            figSortomatoGraph = get(axesGraph, 'Parent');
            guiSortomato = getappdata(figSortomatoGraph, 'guiSortomato');
            
            %% Call the sort function.
            pushregionsortcallback(menuObject, [], figSortomatoGraph, guiSortomato, obj.Name)
        end % sortRegionObjects
        
    end % methods
    
    events
               
    end % events
    
end % sortomatopoly