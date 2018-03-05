function statStruct = xtgetstats(xImarisApp, xObject, varargin)
    % XTGETSTATS Gather Imaris stats into a MATLAB struct
    %
    %   Description
    %   -----------
    %   XTGETSTATS returns stats for an Imaris Spots or Surfaces object
    %   related to the single objects, object tracks or object summary
    %   data.
    %   
    %   Syntax
    %   ------
    %   statStruct = XTGETSTATS(xImarisApp, xObject) returns the
    %   statistical properties for xObject, a child object of the Surpass
    %   scene in the Imaris instance represented by xImarisApp. The output
    %   statStruct is a struct array with fields for each statistical
    %   property, e.g., statStruct.Speed returns a list of speeds for all
    %   the Spots or Surfaces.
    %   
    %   statStruct = XTGETSTATS(..., 'Tracks') returns the stastical
    %   properties associated with the Track data for xObject. Track
    %   statistics are aggregate/average values associated with entire
    %   tracks. Track statistics have IDs >= 1e9. In addition to 'Tracks',
    %   'Singlets' and 'Summary' stats can be specified (see Input
    %   Arguments below for acceptable syntax).
    %   
    %   statStruct = XTGETSTATS(..., 'ReturnUnits', true) returns the
    %   units of measurement for the statistical values in the 'Units'
    %   field.
    %
    %   Examples
    %   --------
    %   xImarisApp = xtconnectimaris(0);
    %   xObject = xImarisApp.GetSurpassSelection;
    %   statStruct = XTGETSTATS(xImarisApp, xObject);
    %   statStruct = XTGETSTATS(xImarisApp, xObject, 'All');
    %   statStruct = XTGETSTATS(xImarisApp, xObject, 'ID', 'ReturnUnits', true);
    %
    %   Input Arguments
    %   ---------------
    %   xImarisApp      An <Imaris.IApplicationPrxHelper> object
    %   xObject         A Spots or Surfaces <Imaris.IDataItemPrxHelper>
    %   'statTypes'     A case-insensitive string from the list:
    %                       'All' (Default)
    %                       'ID' (Returns Single object and Track stats)
    %                       'Singlets'
    %                       'Summary'
    %                       'Tracks'
    %   'ReturnUnits'   A Property/Value pair to return the measurement
    %                   units (default is false/0)
    %
    %   Output
    %   ------
    %   The function returns a struct array with fields for each
    %   statistical property of the Spots or Surfaces in the Surpass
    %   object.
    %   
    %   ©2010-2013, P. Beemiller. Licensed under a Creative Commmons Attribution
    %   license. Please see: http://creativecommons.org/licenses/by/3.0/
    
    %% Parse the input arguments.
    xtgetstatsParser = inputParser;
    
    addRequired(xtgetstatsParser, 'xImarisApp', ...
        @(arg)isa(arg, 'Imaris.IApplicationPrxHelper'))
    
    validateObjectArg = @(arg)validatextobjectarg(arg, xImarisApp);
    addRequired(xtgetstatsParser, 'xObject', validateObjectArg)
    
    validStringArgCell = {'All', 'ID', 'Singlets', 'Summary', 'Tracks'};
    validateStatReturnArg = ...
        @(arg)any(strcmpi(arg, validStringArgCell));
    addOptional(xtgetstatsParser, 'StatType', 'All', validateStatReturnArg);
    
    addParamValue(xtgetstatsParser, 'ReturnUnits', false, @(arg)ismember(arg, [0, 1]))
    
    parse(xtgetstatsParser, xImarisApp, xObject, varargin{:});
    
    %% Get the statistics from Imaris.
    xStats = xObject.GetStatistics;

    mStats.Factors = transpose(cell(xStats.mFactors));
    mStats.FactorNames = cell(xStats.mFactorNames);
    mStats.Ids = xStats.mIds;
    mStats.Names = cell(xStats.mNames);
    mStats.Values = xStats.mValues;
    
    if xtgetstatsParser.Results.ReturnUnits
        mStats.Units = cell(xStats.mUnits);
    end % if
    
    % Dereference the xStats object and call the garbage collector.
    clear xStats
    java.lang.System.gc
    
    %% Get the object and track Ids.
    allIds = unique(mStats.Ids);
    objectIds = allIds(allIds >= 0 & allIds < 1e9);
    trackIds = allIds(allIds >= 1e9);
    
    %% Get the channel ID strings from the Factors. 
    % The second column of the factors field has the channel IDs listed as
    % strings. Convert to numeric.
    mStats.ChannelIds = cellfun(@str2double, mStats.Factors(:, 2));
    
    %% Get the statistics labels and find the channel intensity-related stats.
    [statLabels, firstStatIdxs] = unique(mStats.Names);
    
    % Find the channel-related stats. For channel stats, we need to make c
    % sub-stats for the channels.
    isIntensityStat = ~isnan(mStats.ChannelIds(firstStatIdxs));
    cSize = xImarisApp.GetDataSet.GetSizeC;
    
    %% Construct a logical mask of intensity stats after expanding channel stats.
    isIntensityStatTotalMask = repmat(isIntensityStat', [cSize 1]);
    isExpandedIntensity = isIntensityStatTotalMask(2:end, :) == 1;
    isExpandedIntensity = [true(size(isIntensityStat')); isExpandedIntensity];
    isIntensityStatExpanded = isIntensityStatTotalMask(isExpandedIntensity);
        
    %% Construct an expanded stat name list with the individual channel labels.
    channelLabels = strcat(...
        repmat({' - Channel '}, [cSize 1]), ...
        cellfun(@num2str, num2cell(transpose(1:cSize)), 'UniformOutput', 0));
    channelLabels = repmat(channelLabels, [1, sum(isIntensityStat)]);

    statLabelsExpanded = repmat(statLabels', [cSize, 1]);
    statLabelList = cell(size(isIntensityStatTotalMask));
    statLabelList(1, :) = statLabels;
    statLabelList(isIntensityStatTotalMask) = strcat(...
        statLabelsExpanded(:, isIntensityStat), channelLabels);
    
    % Construct the expanded stat label list, intensity stat mask list and
    % base stat name lists.
    statLabelList = statLabelList(~cellfun(@isempty, statLabelList));
    
    statLabelBaseNames = statLabelList;
    statLabelBaseNames(isIntensityStatExpanded) = regexprep(...
        statLabelList(isIntensityStatExpanded), ' - Channel \d{1,}', '');
    
    %% Find the summary, track, and single object stats indices.
    % Find the Summary stats.
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

    summaryStatMask = ~cellfun(@isempty, ...
        regexp(statLabelList, summaryStatRegexpString, ...
        'Start', 'Once'));
    
    % Find the track stats.
    trackStatMask = strncmp('Track ', statLabelList, 6);

    % Find the singlet stats.
    singleStatMask = ~trackStatMask & ~summaryStatMask;
    
    % Find the indexes for the stats.
    singleStatIdxs = find(singleStatMask);
    summaryStatIdxs = find(summaryStatMask);
    trackStatIdxs = find(trackStatMask);
    
    %% Allocate the output struct with the object IDs and stat names.
    switch lower(xtgetstatsParser.Results.StatType)
        
        case 'id' % single objects or tracks
            getStatIdxs = [singleStatIdxs; trackStatIdxs];
            
            statStruct(1:length(getStatIdxs)) = struct(...
                'Ids', [], ...
                'Name', deal(statLabelList(getStatIdxs)), ...
                'Values', []);
            
            % Add the generic single object data.
            [statStruct(1:length(singleStatIdxs)).Ids] = deal(objectIds);
            [statStruct(1:length(singleStatIdxs)).Values] = deal(nan(size(objectIds)));
            
            % Add the generic track object data.
            [statStruct(length(singleStatIdxs) + 1:end).Ids] = deal(trackIds);
            [statStruct(length(singleStatIdxs) + 1:end).Values] = deal(nan(size(trackIds)));

        case 'singlets'
            % Find the single object indices in the full stats list.
            getStatIdxs = singleStatIdxs;
            
            % Add the generic single object data.
            statStruct(1:length(getStatIdxs)) = struct(...
                'Ids', objectIds, ...
                'Name', deal(statLabelList(getStatIdxs)), ...
                'Values', nan(size(objectIds)));
                            
        case 'summary'
            % Find the single object indices in the full stats list.
            getStatIdxs = summaryStatIdxs;
            
            % Add the generic summary data.
            statStruct(1:length(getStatIdxs)) = struct(...
                'Ids', -1, ...
                'Name', deal(statLabelList(summaryStatIdxs)), ...
                'Values', nan);
                                        
        case 'tracks'
            % Find the single object indices in the full stats list.
            getStatIdxs = trackStatIdxs;
            
            % Add the generic track object data.
            statStruct(1:length(getStatIdxs)) = struct(...
                'Ids', trackIds, ...
                'Name', deal(statLabelList(getStatIdxs)), ...
                'Values', nan(size(trackIds)));
            
        otherwise
            getStatIdxs = 1:length(statLabelList);
            
            statStruct(1:length(getStatIdxs)) = struct(...
                'Ids', [], ...
                'Name', deal(statLabelList), ...
                'Values', []);
            
            % Add the generic single object data.
            [statStruct(singleStatIdxs).Ids] = deal(objectIds);
            [statStruct(singleStatIdxs).Values] = deal(nan(size(objectIds)));
            
            % Add the generic track object data.
            [statStruct(trackStatIdxs).Ids] = deal(trackIds);
            [statStruct(trackStatIdxs).Values] = deal(nan(size(trackIds)));

            % Add the generic summary data.
            [statStruct(summaryStatIdxs).Ids] = deal(-1);
            [statStruct(summaryStatIdxs).Values] = deal(nan);
                                        
    end % switch
    
    %% If the units are requested, allocate a cell to hold the units for each stat.
    if xtgetstatsParser.Results.ReturnUnits
        [statStruct.Units] = deal([]);
    end % if
    
    %% Add the values to the struct.
    % Create a variable for indexing the sth stat and cth channel stat value.
    structIdx = 1;

    % Find the values for each stat and add to the struct.
    for s = 1:length(getStatIdxs)
        % Get the indices for the stat in the Imaris data list.
        sDataIdxs = strcmp(mStats.Names, statLabelBaseNames{getStatIdxs(s)});

        if isIntensityStatExpanded(getStatIdxs(s))
            % Get the indices for the channel data.
            cIdx = regexp(statLabelList(getStatIdxs(s)), '\d{1,}', 'Match', 'Once');
            cDataIdxs = mStats.ChannelIds == str2double(cIdx);
            sDataIdxs = cDataIdxs & sDataIdxs;
        end % if

        % Get the object IDs with data for the stat.
        sStatIDs = mStats.Ids(sDataIdxs);

        % Add the data to the struct.
        if any(singleStatIdxs == getStatIdxs(s))
            sValues = mStats.Values(sDataIdxs);
            [sortedIDs, sStructIdxs] = sort(sStatIDs);
            statStruct(structIdx).Values = sValues(sStructIdxs);

        elseif any(trackStatIdxs == getStatIdxs(s))
            sValues = mStats.Values(sDataIdxs);
            [sortedIDs, sStructIdxs] = sort(sStatIDs);
            statStruct(structIdx).Values = sValues(sStructIdxs);

        else
            statStruct(structIdx).Ids = sStatIDs;
            statStruct(structIdx).Values = mStats.Values(sDataIdxs);

        end % if

        % Add the data units if requested.
        if xtgetstatsParser.Results.ReturnUnits
            statStruct(structIdx).Units = mStats.Units{find(sDataIdxs, 1, 'first')};
        end % if

        % Update the position in the struct.
        structIdx = structIdx + 1;
    end % for s
end % xtgetstats


function isValidXTObject = validatextobjectarg(xObject, xImarisApp)
    % VALIDATEXTOBJECTARG Test for a valid Imaris Spots or Surfaces object
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