function [xImarisApp, xImarisID, isNewInstance] = xtconnectimaris(varargin)
    % XTCONNECTIMARIS Connect to a new or running Imaris instance
    %
    % Syntax
    % ------
    % xImarisApp = XTCONNECTIMARIS(xImarisApp) connects to the Imaris
    % instance indicated by the integer value xImarisID. If no running
    % Imaris instance is assigned the ID represented by xImarisID, a new
    % instance with ID xImarisID will be started and connected.
    %
    % xImarisApp = XTCONNECTIMARIS will start and connect to a new Imaris
    % instance.
    %
    % [xImarisApp, xImarisID] = XTCONNECTIMARIS will start and connect to a
    % new Imaris instance, as well as return the ID of the Imaris instance
    % in xImarisID.
    %
    % [xImarisApp, xImarisID, isNewInstance] = xtconnectimaris(xImarisID)
    % a logical value (0 or 1) indicating whether a new Imaris instance was
    % started.
    % 
    % Examples
    % -------
    % Connect to a specific Imaris instance:
    % xImarisApp = xtconnectimaris(xImarisID);
    %
    % Create a new Imaris instance, connect to it and return its ID:
    % [xImarisApp, xImarisID] = xtconnectimaris;
    %
    % ©2013, P. Beemiller. Licensed under a Creative Commmons Attribution
    % license. See: http://creativecommons.org/licenses/by/3.0/

    %% Parse the optional input.
    xtconnectimarisParser = inputParser;
    
    addOptional(xtconnectimarisParser, 'xImarisID', [], ...
        @(arg)inputvalidationfcn(arg))
    
    parse(xtconnectimarisParser, varargin{:})
    
    % Convert the input argument using str2double if necessary.
    if nargin == 1 && ischar(varargin{1})
        xImarisID = round(str2double(varargin{1}));
        
    elseif nargin == 1
        xImarisID = varargin{1};
        
    end % if
    
    %% Get the install folder for program files.
    programsFolder = getenv('PROGRAMFILES');
    
    %% Find the highest Imaris version on the computer.
    imarisFolders = dir(fullfile(programsFolder, 'Bitplane\Imaris*'));
    imarisVerStrs = regexp({imarisFolders.name}', '(\d)\.(\d)\.(\d)$', 'Match', 'Once');
    imarisVerStrs = regexprep(imarisVerStrs, '\.', '');
    imarisVerNos = cellfun(@str2double, imarisVerStrs);
    imarisConnectFolder = imarisFolders(imarisVerNos == max(imarisVerNos)).name;

    %% Create a new object from the ImarisLib class.
    if all(cellfun(@isempty, regexp(javaclasspath('-all'), 'ImarisLib.jar$', 'once')))
        % Construct the path string to the .jar file.
        imarislibPath = fullfile(programsFolder, 'Bitplane', imarisConnectFolder, ...
            'XT\matlab\ImarisLib.jar');
        
        % Hackish solution to multiple imaris versions installed problem
        % Simply assume this script is installed in the 'private' subdir
        % of the place where the ImarisLib.jar file is installed
        imarislibPath = fullfile(fileparts(fileparts(mfilename('fullpath'))),'ImarisLib.jar');
        
        if isdeployed
            	warning off MATLAB:javaclasspath:jarAlreadySpecified
                javaaddpath(imarislibPath)
                warning on MATLAB:javaclasspath:jarAlreadySpecified

        else
            javaaddpath(imarislibPath)
            
        end % if
    end % if
    
    xImarisLib = ImarisLib;

    %% Find the running Imaris instances.
    xImarisServer = xImarisLib.GetServer;    
    
    try
        xImarisObjectCount = xImarisServer.GetNumberOfObjects;
        
        xImarisIDs = zeros(xImarisObjectCount, 1);
        for x = 1:xImarisObjectCount
            xImarisIDs(x) = xImarisServer.GetObjectID(x - 1);
        end % for
    
    catch xImarisME
        xImarisObjectCount = 0;
        
    end % catch
    
    %% Create the connection to Imaris.
    if xImarisObjectCount ~= 0
        switch nargin
            
            case 0
                % Generate an ID to use.
                xImarisID = max(xImarisIDs) + 1;
                
                % Construct the path string to the Imaris version we want to launch.        
                imarisPath = fullfile(...
                    programsFolder, 'Bitplane', imarisConnectFolder, 'Imaris.exe');
                imarisPath = ['"' strrep(imarisPath, '\', '\\') '"'];

                bangString = sprintf([imarisPath ' -id%i &'], xImarisID);
                system(bangString);

                % Attempt to connect to the instance while we wait for it to register.
                xImarisApp = xImarisLib.GetApplication(xImarisID);

                while isempty(xImarisApp)
                    xImarisApp = xImarisLib.GetApplication(xImarisID);
                    pause(1)
                end % while
                
                if nargout == 3
                    isNewInstance = 0;
                end % if

            case 1
                if any(ismember(xImarisIDs, xImarisID))
                    xImarisApp = xImarisLib.GetApplication(xImarisID);
                    
                    if nargout == 3
                        isNewInstance = 0;
                    end % if

                else
                    % Construct the path string to the Imaris version we want to launch.        
                    imarisPath = fullfile(...
                        programsFolder, 'Bitplane', imarisConnectFolder, 'Imaris.exe');
                    imarisPath = ['"' strrep(imarisPath, '\', '\\') '"'];

                    bangString = sprintf([imarisPath ' -id%i &'], xImarisID);
                    system(bangString);

                    % Attempt to connect to the instance while we wait for it to register.
                    xImarisApp = xImarisLib.GetApplication(xImarisID);

                    while isempty(xImarisApp)
                        xImarisApp = xImarisLib.GetApplication(xImarisID);
                        pause(1)
                    end % while
                    
                    if nargout == 3
                        isNewInstance = 1;
                    end % if

                end % if
        
        end % switch
        
    else
        switch nargin
            
            case 0
                % Generate an ID to use.
                xImarisID = 0;
                
                % Construct the path string to the Imaris version we want to launch.
                imarisPath = fullfile(...
                    programsFolder, 'Bitplane', imarisConnectFolder, 'Imaris.exe');
                imarisPath = ['"' strrep(imarisPath, '\', '\\') '"'];

                bangString = sprintf([imarisPath ' -id%i &'], xImarisID);
                system(bangString);

                % Attempt to connect to the instance while we wait for it to register.
                xImarisApp = xImarisLib.GetApplication(xImarisID);

                while isempty(xImarisApp)
                    xImarisApp = xImarisLib.GetApplication(xImarisID);
                    pause(1)
                end % while

                if nargout == 3
                    isNewInstance = 0;
                end % if

            case 1
                % Construct the path string to the Imaris version we want to launch.
                imarisPath = fullfile(...
                    programsFolder, 'Bitplane', imarisConnectFolder, 'Imaris.exe');
                imarisPath = ['"' strrep(imarisPath, '\', '\\') '"'];

                bangString = sprintf([imarisPath ' -id%i &'], xImarisID);
                system(bangString);

                % Attempt to connect to the instance while we wait for it to register.
                xImarisApp = xImarisLib.GetApplication(xImarisID);

                while isempty(xImarisApp)
                    xImarisApp = xImarisLib.GetApplication(xImarisID);
                    pause(1)
                end % while
                
                if nargout == 3
                    isNewInstance = 0;
                end % if

        end % switch
        
    end % if
end % xtconnectimaris


%% Input validation function
function isValidInput = inputvalidationfcn(xImarisID)
    %
    %
    %
    
    %% If the input is a string, check for a valid conversion to double.
    if ischar(xImarisID)
        doubleID = str2double(xImarisID);
        
        if isnan(doubleID)
            isValidInput = 0;
            return
        end % if
    
    else
        doubleID = xImarisID;
        
    end % if
    
    %% Check for an integer input value (not type!).
    if rem(doubleID, 1) ~= 0
        isValidInput = 0;
        
    else
        isValidInput = 1;
        
    end % if
end % inputvalidationfcn