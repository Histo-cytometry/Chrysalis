function XTStatisticsExport(aImarisApplicationID)

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

import java.util.Properties
import java.io.FileReader

% Finds out where the current m file is
baseFolder = fileparts(which(mfilename));

% Reads the property file from the same directory of the m file
propertyFilename = fullfile(baseFolder,'chrysalis.properties');
p = Properties; 
p.load(FileReader(propertyFilename)); 

% Read the property
outputPath = p.getProperty('outputPath');
convertedPath = char(outputPath);

vFileNameString = vImarisApplication.GetCurrentFileName; % returns ‘C:/Imaris/Images/retina.ims’
vFileName = char(vFileNameString);
[vOldFolder, vName, vExt] = fileparts(vFileName); % returns [‘C:/Imaris/Images/’, ‘retina’, ‘.ims’]
vNewFileName = fullfile(convertedPath, [vName, vExt]); % returns ‘c:/BitplaneBatchOutput/retina.ims’

%%%%%% Export all stats for surfaces starting with TCR
saveTable(vImarisApplication, vNewFileName, offset);
saveTable(vImarisApplication, vNewFileName, 0);

end

function saveTable(vImarisApplication, vNewFileName, offset)

surpassObjects = xtgetsporfaces(vImarisApplication);
names = {surpassObjects.Name};

for vv = 1:length(surpassObjects)
    xObject = surpassObjects(vv).ImarisObject;

    statStruct = xtgetstats(vImarisApplication, xObject, 'ID', 'ReturnUnits', 1);
    
    statNames = {statStruct.Name};
    
    filename = [vNewFileName(1:end-4) ' - ' names{vv} ' - offset' num2str(offset) '.csv'];
    
    fd = fopen(filename,'w');
    %t = table;
    
    allstats = {'Intensity Mean','Intensity Min','Position','Area','Volume','Sphericity'};
    
    headers = {};
    data = {double(statStruct(1).Ids)};
    
    for statn = 1:length(allstats)
        pat = allstats{statn};
        
        % Save Intensity Mean
        imeans = find(cellfun(@(x) ~isempty(strfind(x,pat)),statNames));

        for i = 1:length(imeans)
            imean = imeans(i);

            headers{end+1} = statNames{imean};
            
            data{end+1} = statStruct(imean).Values+offset;

            %t.(statNames{imean})=v;
        end
    end
    
    headerString = sprintf('%s,',headers{:});
    headerString = ['ID,' headerString(1:end-1)];
    
    fprintf(fd,'%s\n',headerString);
    fprintf(fd,[repmat('%f,',1,numel(data)-1) '%f\n'],cat(2,data{:})');
    
    fclose(fd);
end

end
