function xSurpassObjects = xtgetsporfaces(xImarisApp, varargin)
    % XTGETSPORFACES Get the Spots and Surfaces objects from Imaris
    %   XTGETSPORFACES returns a struct containing the Spots and/or
    %   Surfaces child objects from the Surpass scene of the input Imaris XT
    %   application.
    %   
    %   Syntax
    %   ------
    %   xObjects = xtgetsporfaces(xImarisApp);
    %   xObjects = xtgetsporfaces(xImarisApp, 'Spots');
    %
    %   Description
    %   -----------
    %   xObjects = xtgetsporfaces(xImarisApp) returns the Spots and
    %   Surfaces object in the Imaris application instance represented by
    %   xImarisApp.
    %
    %   xSurfaces = xtgetsporfaces(xImarisApp, 'Surfaces') returns only the
    %   Surfaces objects from the Imaris appplication. Spots can also be
    %   returned independently.
    %
    %   Input Arguments
    %   ---------------
    %   xImarisApp      An <Imaris.IApplicationPrxHelper> object.
    %   statTypes       A case-insensitive string from the list:
    %                       'Both' (Default)
    %                       'Spots' (Returns Spots and Surfaces)
    %                       'Surfaces'
    %   
    %   The output is a struct with the fields 'ImarisObject', 'Name' and
    %   'Type'. The ImarisObject field is an <Imaris.IDataItemPrxHelper>
    %   object that can be used to access the Spot/Surface object. The Name
    %   field is the char string displayed by the Imaris Surpass scene. The
    %   Type field is a string matching either 'Spots' or 'Surfaces'.
    %

    %% Parse the inputs.
    xtgetsporfacesParser = inputParser;
    
    addRequired(xtgetsporfacesParser, 'xImarisApp', ...
        @(arg)isa(arg, 'Imaris.IApplicationPrxHelper'))
    
    validationFcn = @(arg)any(strcmpi(arg, {'Spots', 'Surfaces', 'Both'}));
    addOptional(xtgetsporfacesParser, 'SurfaceType', 'Both', validationFcn);
    
    parse(xtgetsporfacesParser, xImarisApp, varargin{:})
    
    %% Allocate the output struct.
    xSurpassObjects = struct('Name', {}, 'ImarisObject', [], 'Type', {});
    
    % If there is no scene, return an empty array.
    xScene = xImarisApp.GetSurpassScene;
    if isempty(xScene)
        xSurpassObjects = [];
        return
    end % if

    %% Get the Surpass objects.
    % Create a factory handle.
    xFactory = xImarisApp.GetFactory;

    % Use a switch case to return either the Spots, Surfaces or both.
    switch lower(xtgetsporfacesParser.Results.SurfaceType)

        case 'both'
            for c = 1:xScene.GetNumberOfChildren
                % Get the next child of the Surpass container.
                cChild = xScene.GetChild(c - 1);

                % If the child is a Surfaces or Spots object, add it to the list.
                if xFactory.IsSpots(cChild)
                    % Cast to Spots.
                    cChild = xFactory.ToSpots(cChild);
                    
                    % Add to the struct.
                    xSurpassObjects(length(xSurpassObjects) + 1).ImarisObject = cChild;
                    xSurpassObjects(length(xSurpassObjects)).Name = char(cChild.GetName);
                    xSurpassObjects(length(xSurpassObjects)).Type = 'Spots';
                
                elseif xFactory.IsSurfaces(cChild)
                    % Cast to Surfaces.
                    cChild = xFactory.ToSurfaces(cChild);
                    
                    % Add to the struct.
                    xSurpassObjects(length(xSurpassObjects) + 1).ImarisObject = cChild;
                    xSurpassObjects(length(xSurpassObjects)).Name = char(cChild.GetName);
                    xSurpassObjects(length(xSurpassObjects)).Type = 'Surfaces';
                                   
                end % if
            end % for m

        case 'spots'
            for c = 1:xScene.GetNumberOfChildren
                % Get the next child of the Surpass container.
                cChild = xScene.GetChild(c - 1);

                % If the child is a Spots object, add it to the list.
                if xFactory.IsSpots(cChild)
                    % Cast to Spots.
                    cChild = xFactory.ToSpots(cChild);
                    
                    % Add to the struct.
                    xSurpassObjects(length(xSurpassObjects) + 1).ImarisObject = cChild;
                    xSurpassObjects(length(xSurpassObjects)).Name = char(cChild.GetName);
                    xSurpassObjects(length(xSurpassObjects)).Type = 'Spots';
                end % if
            end % for m

        case 'surfaces'
            for c = 1:xScene.GetNumberOfChildren
                % Get the next child of the Surpass container.
                cChild = xScene.GetChild(c - 1);

                % If the child is a Surfaces object, add it to the list.
                if xFactory.IsSurfaces(cChild)
                    % Cast to Surfaces.
                    cChild = xFactory.ToSurfaces(cChild);
                    
                    % Add to the struct.
                    xSurpassObjects(length(xSurpassObjects) + 1).ImarisObject = cChild;
                    xSurpassObjects(length(xSurpassObjects)).Name = char(cChild.GetName);
                    xSurpassObjects(length(xSurpassObjects)).Type = 'Surfaces';
                end % if
            end % for m

    end % switch
end % xtgetsporfaces
