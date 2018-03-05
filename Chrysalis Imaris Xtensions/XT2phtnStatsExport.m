%
%  Batch Kiss and Run for surfaces
%
function XT2phtnStatsExport(aImarisApplicationID)

% Parameters
offset = 0.1;

% connect to Imaris interface
if ~isa(aImarisApplicationID, 'Imaris.IApplicationPrxHelper')
    javaaddpath ImarisLib.jar
    vImarisLib = ImarisLib;
    if ischar(aImarisApplicationID)
        aImarisApplicationID = round(str2double(aImarisApplicationID));
    end
    vImarisApplication = vImarisLib.GetApplication(aImarisApplicationID);
else
    vImarisApplication = aImarisApplicationID;
end

vFileNameString = vImarisApplication.GetCurrentFileName; % returns ‘C:/Imaris/Images/retina.ims’
vFileName = char(vFileNameString);
[vOldFolder, vName, vExt] = fileparts(vFileName); % returns [‘C:/Imaris/Images/’, ‘retina’, ‘.ims’]
vNewFileName = fullfile('g:/BitplaneBatchOutput', [vName, vExt]); % returns ‘c:/BitplaneBatchOutput/retina.ims’

saveTableTracks(vImarisApplication, 'TCR', vNewFileName, offset);
saveTableTracks(vImarisApplication, 'DC', vNewFileName, offset);
saveTableTracks(vImarisApplication, 'TCR', vNewFileName, 0);
saveTableTracks(vImarisApplication, 'DC', vNewFileName, 0);

saveTableSinglets(vImarisApplication, 'TCR', vNewFileName, offset);
saveTableSinglets(vImarisApplication, 'TCR', vNewFileName, 0);

end

function saveTableTracks(vImarisApplication, pattern, vNewFileName, offset)

surpassObjects = xtgetsporfaces(vImarisApplication);
names = {surpassObjects.Name};
listValue = find(cellfun(@(x) ~isempty(strfind(x,pattern)),names));

for i_surf = 1:length(listValue)
    vv = listValue(i_surf);
    xObject = surpassObjects(vv).ImarisObject;
    
    statStruct = xtgetstats(vImarisApplication, xObject, 'Tracks', 'ReturnUnits', 1);
    
    statNames = {statStruct.Name};
    statUnits = {statStruct.Units};
    
    filename = [vNewFileName(1:end-4) ' - ' names{vv} ' - offset' num2str(offset) '.csv'];
    
    fd = fopen(filename,'w');
    %t = table;
    
    allstats = {'Track Duration','Track Displacement','Track Length','Track Speed','Track Position','Track Straightness','contact'};
    
    headers = {};
    data = {double(statStruct(1).Ids)};
    
    for statn = 1:length(allstats)
        pat = allstats{statn};
        
        % Save Intensity Mean
        imeans = find(cellfun(@(x) ~isempty(strfind(x,pat)),statNames));
        
        for i = 1:length(imeans)
            imean = imeans(i);
            
            sname = statNames{imean};
            sunit = statUnits{imean};
            
            [startIndex, endIndex, tokIndex, matchStr, tokenStr, exprNames, splitStr] = regexp(sname,'Channel (?<ChNo>[0-9]+)');
            
            if ~isempty(startIndex)
                chNo = str2double(exprNames.ChNo);
                
                chanName = char(vImarisApplication.GetDataSet.GetChannelName(chNo-1));
                
                sname = [sname(1:startIndex-1) chanName];
            end
            
            % Calculate conversion factor for minutes
            if strcmp(sunit,'min') || strcmp(sunit,'sec') || strcmp(sunit,'s')
                cf = 1/60;
                sunit = 'min';
            elseif strcmp(sunit,'um/min') || strcmp(sunit,'um/s') 
                cf = 60;
                sunit = 'um/min';
            else
                cf = 1;
            end
            
            headers{end+1} = [sname ' (' sunit ')'];
            data{end+1} = statStruct(imean).Values * cf + offset;
            
            %t.(statNames{imean})=v;
        end
    end
    
    headerString = sprintf('%s,',headers{:});
    headerString = ['ID,' headerString(1:end-1)];
    
    fprintf(fd,'%s\n',headerString);
    for ir = 1:length(data{1})
        for ic = 1:length(data)
            if ic==1
                fprintf(fd,'%d,',data{ic}(ir));
            else
                fprintf(fd,'%f,',data{ic}(ir));
            end
        end
        fprintf(fd,'\n');
    end
    %fprintf(fd,[repmat('%f,',1,numel(data)-1) '%f\n'],cat(2,data{:})');
    
    fclose(fd);
    
    %writetable(t,filename);
end

end

function saveTableSinglets(vImarisApplication, pattern, vNewFileName, offset)
allstatsTrack = {'Track Duration','Track Displacement','Track Length','Track Speed','Track Position','Track Straightness','contact'};
allstats = {'Speed','Distance to','Sphericity','Time','Intensity Mean','Intensity Min', 'Volume'};

surpassObjects = xtgetsporfaces(vImarisApplication);
names = {surpassObjects.Name};
listValue = find(cellfun(@(x) ~isempty(strfind(x,pattern)),names));

for i_surf = 1:length(listValue)
    vv = listValue(i_surf);
    xObject = surpassObjects(vv).ImarisObject;
    
    statStructTracks = xtgetstats(vImarisApplication, xObject, 'Tracks', 'ReturnUnits', 1);
    statStruct = xtgetstats(vImarisApplication, xObject, 'Singlets', 'ReturnUnits', 1);
    
    singletIds = unique(cat(1,statStruct.Ids));
    
    tids = round(xObject.GetTrackIds);
    tedges_ = round(xObject.GetTrackEdges);
    tedges = arrayfun(@(id_) singletIds(id_),tedges_+1);
    edgesTable = [tids tedges(:,1); tids tedges(:,2)];
    
    statNames = {statStruct.Name};
    statUnits = {statStruct.Units};
    
    statNamesTrack = {statStructTracks.Name};
    statUnitsTrack = {statStructTracks.Units};
    
    dirname = [vNewFileName(1:end-4) ' - ' names{vv} ' - offset' num2str(offset)];
    mkdir(dirname);

    bigfilename = [dirname ' singlets.csv'];
    bigdata = {};
    
    allIds = double(statStructTracks(1).Ids)';
    allIds = allIds(allIds>0);
    
    for id = allIds
        filename = fullfile(dirname,[pattern ' ID' num2str(id) '-offset' num2str(offset) '.csv']);
        
        fd = fopen(filename,'w');
        %t = table;

        headers = {};

        % Find corresponding track
        corrSinglets = unique(edgesTable(find(edgesTable(:,1)==id),2));
        
        data = {corrSinglets};
        
        %trackStats = statStructTracks(filt);
        
        for statn = 1:length(allstats)
            pat = allstats{statn};

            % Save Intensity Mean
            imeans = find(cellfun(@(x) ~isempty(strfind(x,pat)),statNames));
            %imeans = find(strcmp(pat,statNames));

            for i = 1:length(imeans)
                imean = imeans(i);

                sname = statNames{imean};
                sunit = statUnits{imean};

                [startIndex, endIndex, tokIndex, matchStr, tokenStr, exprNames, splitStr] = regexp(sname,'Channel (?<ChNo>[0-9]+)');

                if ~isempty(startIndex)
                    chNo = str2double(exprNames.ChNo);

                    chanName = char(vImarisApplication.GetDataSet.GetChannelName(chNo-1));

                    sname = [sname(1:startIndex-1) chanName];
                end

                % Calculate conversion factor for minutes
                if strcmp(sunit,'min') || strcmp(sunit,'sec') || strcmp(sunit,'s')
                    cf = 1/60;
                    sunit = 'min';
                elseif strcmp(sunit,'um/min') || strcmp(sunit,'um/s') 
                    cf = 60;
                    sunit = 'um/min';
                else
                    cf = 1;
                end
                
                filt = ismember(statStruct(imean).Ids,corrSinglets);

                headers{end+1} = [sname ' (' sunit ')'];
                data{end+1} = statStruct(imean).Values(filt) * cf + offset;

                %t.(statNames{imean})=v;
            end
        end

        for statn = 1:length(allstatsTrack)
            pat = allstatsTrack{statn};
            
            imeans = find(~cellfun(@isempty,strfind(statNamesTrack,pat)));
            %imeans = imeans & filt;

            for i = 1:length(imeans)
                imean = imeans(i);

                sname = statNamesTrack{imean};
                sunit = statUnitsTrack{imean};

                [startIndex, endIndex, tokIndex, matchStr, tokenStr, exprNames, splitStr] = regexp(sname,'Channel (?<ChNo>[0-9]+)');

                if ~isempty(startIndex)
                    chNo = str2double(exprNames.ChNo);

                    chanName = char(vImarisApplication.GetDataSet.GetChannelName(chNo-1));

                    sname = [sname(1:startIndex-1) chanName];
                end

                % Calculate conversion factor for minutes
                if strcmp(sunit,'min') || strcmp(sunit,'sec') || strcmp(sunit,'s')
                    cf = 1/60;
                    sunit = 'min';
                elseif strcmp(sunit,'um/min') || strcmp(sunit,'um/s') 
                    cf = 60;
                    sunit = 'um/min';
                else
                    cf = 1;
                end

                Nrows = length(data{1});
                headers{end+1} = [sname ' (' sunit ')'];
                data{end+1} = repmat(statStructTracks(imean).Values(statStructTracks(imean).Ids==id) * cf + offset,Nrows,1);

                %t.(statNames{imean})=v;
            end
        end
        
        headers = cat(2,{['ID']},headers);
        data = cat(2,{repmat(id,Nrows,1)},data);        
        bigdata = cat(3,bigdata,data); % Concatenate along the third dimension
        
        headerString = sprintf('%s,',headers{:});
        headerString = ['Track ID,' headerString(1:end-1)];

        fprintf(fd,'%s\n',headerString);
        for ir = 1:length(data{1})
            for ic = 1:length(data)
                if ic==1
                    fprintf(fd,'%d,',data{ic}(ir));
                else
                    fprintf(fd,'%f,',data{ic}(ir));
                end
            end
            fprintf(fd,'\n');
        end
        %fprintf(fd,[repmat('%f,',1,numel(data)-1) '%f\n'],cat(2,data{:})');

        fclose(fd);
    end    
    
    % Write the big data file for this surf
    % We have the headers
    bigfd = fopen(bigfilename,'w');
    fprintf(bigfd,'%s\n',headerString);
    for it = 1:size(bigdata,3)
        for ir = 1:length(bigdata{1,ic,it})
            for ic = 1:size(bigdata,2)
                if ic==1
                    fprintf(bigfd,'%d,',bigdata{1,ic,it}(ir));
                else
                    fprintf(bigfd,'%f,',bigdata{1,ic,it}(ir));
                end
            end
            fprintf(bigfd,'\n');
        end
    end
    fclose(bigfd);

    %writetable(t,filename);
end

end