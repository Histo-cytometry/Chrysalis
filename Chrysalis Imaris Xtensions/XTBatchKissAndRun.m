%
%  Batch Kiss and Run for surfaces
%
function XTBatchKissAndRun(aImarisApplicationID)

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

import java.util.Properties;
import java.io.FileReader;

% Finds out where the current m file is
baseFolder = fileparts(which(mfilename));

% Reads the property file from the same directory of the m file
propertyFilename = fullfile(baseFolder,'chrysalis.properties');
p = Properties; 
p.load(FileReader(propertyFilename)); 

% Read the property
outputPath = p.getProperty('outputPath');

vFileNameString = vImarisApplication.GetCurrentFileName; % returns ‘C:/Imaris/Images/retina.ims’
vFileName = char(vFileNameString);
[vOldFolder, vName, vExt] = fileparts(vFileName); % returns [‘C:/Imaris/Images/’, ‘retina’, ‘.ims’]
vNewFileName = fullfile('outputPath', [vName, vExt]); % returns ‘c:/BitplaneBatchOutput/retina.ims’

Analyze(vImarisApplication);

vImarisApplication.FileSave(vNewFileName, '');

end

function Analyze(vImarisApplication)


% connect to Imaris interface
if isa(vImarisApplication, 'Imaris.IApplicationPrxHelper')
    
    qSurfaceOverlap='NO';
    qCreateColocSurface='NO';
    qDistanceTransform='YES';
    qCreateDistanceTransformChannel='YES';
    
    qNumberofContacts='YES';
    qNumberofProlongedContacts='YES';
    qPercentNumberofContacts='YES';
    qTotalContactTime='YES';
    qTotalTrackDurationAway='YES';
    qLongestContactEvent='YES';
    qMeanContactEvent='YES';
    
    vSpotsSelected=0;
    
    %%
    % the user has to create a scene with some surfaces
    vSurpassScene = vImarisApplication.GetSurpassScene;
    if isequal(vSurpassScene, [])
        msgbox('Please create some Surfaces in the Surpass scene!');
        return;
    end
    
    
    %%
    % get all Surpass surfaces names
    vSurfaces = vImarisApplication.GetFactory.ToSurfaces(vImarisApplication.GetSurpassSelection);
    vSurfacesSelected = vImarisApplication.GetFactory.IsSurfaces(vSurfaces);
    vSpots=vImarisApplication.GetFactory.ToSpots(vImarisApplication.GetSurpassSelection);
    if vSurfacesSelected
        vScene = vSurfaces.GetParent;
        CurrentSurface=char(vSurfaces.GetName);
        Selected='YES';
    else
        vScene = vImarisApplication.GetSurpassScene;
        Selected='NO';
    end
    
    vNumberOfSurfaces = 0;
    vSurfacesList{vScene.GetNumberOfChildren} = [];
    vNamesList{vScene.GetNumberOfChildren} = [];
    for vChildIndex = 1:vScene.GetNumberOfChildren
        vDataItem = vScene.GetChild(vChildIndex - 1);
        if vImarisApplication.GetFactory.IsSurfaces(vDataItem)
            vNumberOfSurfaces = vNumberOfSurfaces+1;
            vSurfacesList{vNumberOfSurfaces} = vImarisApplication.GetFactory.ToSurfaces(vDataItem);
            vNamesList{vNumberOfSurfaces} = char(vDataItem.GetName);
        end
    end
    
    Rnew = vNamesList(~cellfun(@isempty, vNamesList));%Remove Surpass scene object preselected
    
    if vNumberOfSurfaces<2 && vSpotsSelected==0
        msgbox('Please create at least 2 surfaces objects!');
        return;
    end
    
    vNamesList = vNamesList(1:vNumberOfSurfaces);
    %%
    %Choose the surfaces
    
    DC_channel = find(cellfun(@(x) ~isempty(strfind(x,'DC')),vNamesList),1);
    TCR_channels = cellfun(@(x) ~isempty(strfind(x,'TCR')),vNamesList);
    
    vTargetSurface = vSurfacesList{DC_channel};
    vSurfaces = vSurfacesList(TCR_channels);
    
    %%
    %Get Image Data parameters
    vDataMin = [vImarisApplication.GetDataSet.GetExtendMinX, vImarisApplication.GetDataSet.GetExtendMinY, vImarisApplication.GetDataSet.GetExtendMinZ];
    vDataMax = [vImarisApplication.GetDataSet.GetExtendMaxX, vImarisApplication.GetDataSet.GetExtendMaxY, vImarisApplication.GetDataSet.GetExtendMaxZ];
    vDataSize = [vImarisApplication.GetDataSet.GetSizeX, vImarisApplication.GetDataSet.GetSizeY, vImarisApplication.GetDataSet.GetSizeZ];
    aSizeC = vImarisApplication.GetDataSet.GetSizeC;
    aSizeT = vImarisApplication.GetDataSet.GetSizeT;
    
    Xvoxelspacing= (vDataMax(1)-vDataMin(1))/vDataSize(1);
    Zvoxelspacing = (vDataMax(3)-vDataMin(3))/vDataSize(3);
    vSmoothingFactor=Xvoxelspacing*2;
    
    
    if isequal (qCreateColocSurface,'YES') && vSpotsSelected==0;
        %add additional channel
        TotalNumberofChannels=aSizeC+1;
        vLastChannel=TotalNumberofChannels-1;
        %clone Dataset
        vDataSet = vImarisApplication.GetDataSet.Clone;
        vDataSet.SetSizeC(aSizeC + 1);
        
        %Generate dialog for smoothed or unsmoothed surface
        %Have option to chose: 1) no smoothing, 2) default, 3) Custom
        %vSurfaceSmoothingType = false;
        %qstring={'Please choose a how to generate Coloc surface '}
        %vAnswer = questdlg(qstring, 'Colocalize Surfaces', ...
        %        'No Smoothing', 'Smoothing', 'Smoothing');
        %if(isequal(vAnswer, 'Cancel') || isempty(vAnswer))
        %    return
        %end
        %vSurfaceSmoothingType = isequal(vAnswer, 'Smoothing');
        %if vSurfaceSmoothingType==true
        %    vSmoothingFactorName = num2str(vSmoothingFactor);
        %    qstring={'Please set the smoothing factor -- default is double image voxel size'};
        %    vAnswer2 = inputdlg(qstring,'Smoothing Factor',1,{vSmoothingFactorName});
        %    if isempty(vAnswer2), return, end
        %else
        vSmoothingFactor = 0;
        %end
    end
    %%
    %Identify ID for each track
    vSurfacess = vSurfaces;
    for vSurfacesi = 1:length(vSurfacess)
        vSurfaces = vSurfacess{vSurfacesi};
        
        vAllIds = vSurfaces.GetIds;
        edges = vSurfaces.GetTrackEdges + 1;
        TrackIds=vSurfaces.GetTrackIds;
        
        
        if ~isempty(edges)
            edges_forspots = 1:size(vAllIds);%size(vTracks.GetPositionsXYZ, 1);
            edges_forspots( : ) = size(edges, 1) + 1; % initialize array to fictive edge
            edges_forspots(edges(:, 1)) = 1:size(edges, 1);
            edges_forspots(edges(:, 2)) = 1:size(edges, 1);
            trackid_foredges = [TrackIds; 0]; % add fictive track id
            trackid_forspots = trackid_foredges(edges_forspots);
            %convert TrackID into a single integer
            OriginalTrackID = double(trackid_forspots);
            vtrackID = OriginalTrackID-1000000000;
            vtrackIDmax = max(vtrackID);
        else
            vtrackIDmax=0;
            vtrackID=zeros(numel(vAllIds),1);
        end
        %Set the size of the new variable for overlap volume
        vAllTimeIndices=[];
        vNumberofContactsTotal=[];
        
        
        %%
        
        if isequal (qDistanceTransform, 'YES')
            
            %Identify the vAllTimeIndices points that contain tracked surfaces
            if vSpotsSelected==1
                vAllTimeIndices=vSpots.GetIndicesT;
            else
                for GetTimeIndex = 0:size(vAllIds,1)-1;
                    vAllTimeIndices=[vAllTimeIndices;vSurfaces.GetTimeIndex(GetTimeIndex)];
                end
            end
            vValidTimePoints=unique (vAllTimeIndices);
                
            if vSurfacesi==1
                vImarisDataSet = vImarisApplication.GetDataSet.Clone;
                vNumberOfChannels = vImarisDataSet.GetSizeC;
                vImarisDataSet.SetSizeC(vImarisDataSet.GetSizeC + 1);%Add new channel
                %Convert to 32bit
                vImarisDataSet.SetType(vImarisDataSet.GetType.eTypeFloat);
                % Create a new channel where the result will be sent
                vImarisDataSet.SetChannelName(vNumberOfChannels,['Distance to ', char(vTargetSurface.GetName)]);
                vImarisDataSet.SetChannelColorRGBA(vNumberOfChannels, 255*256*256);
                %Get Distance threshold from user input
                DistanceThreshold=0;%

                vProgressDisplay = waitbar(0, 'Distance Transform: Preparation');
                %Calculate distance transform for each vAllTimeIndices point
                for vTime = 0:size(vValidTimePoints,1)-1
                    CurrentTimePoint=vValidTimePoints(vTime+1);
                    vMaskDataSetTarget = vTargetSurface.GetMask( ...
                        vDataMin(1), vDataMin(2), vDataMin(3), ...
                        vDataMax(1), vDataMax(2), vDataMax(3), ...
                        vDataSize(1), vDataSize(2), vDataSize(3), CurrentTimePoint);
                    for vIndexZ = 1:vDataSize(3)
                        vSlice=vMaskDataSetTarget.GetDataSubVolumeAs1DArrayBytes(...
                            0,0,vIndexZ-1,0,0,vDataSize(1),vDataSize(2),1);
                        vSlice = vSlice == 1;%Outside Mask

                        %Remove border voxels and set to zero
                        %vSlice(1:5,:)=0;%set first row to zero
                        %vSlice((end-(vDataSize(1)-1)):end,:)=0;%Set last row to zero
                        %vSlice(1:vDataSize(1):end)=0;%set left left to zero
                        %vSlice(vDataSize(1):vDataSize(1):end)=0;%Set right side to zero

                        vImarisDataSet.SetDataSubVolumeAs1DArrayFloats(vSlice, ...
                            0,0,vIndexZ-1,vNumberOfChannels,CurrentTimePoint,vDataSize(1),vDataSize(2),1);
                    end
                    waitbar((vTime+1+1)/(size(vValidTimePoints,1)), vProgressDisplay);
                end
                waitbar(0.5, vProgressDisplay, 'Distance Transform: Calculation');
                vImarisApplication.GetImageProcessing.DistanceTransformChannel( ...
                    vImarisDataSet, vNumberOfChannels, 1, false);
                waitbar(1, vProgressDisplay);
                close (vProgressDisplay);
                vImarisApplication.SetDataSet(vImarisDataSet);
            end
            
            %Get Original Stats order vNewSpots
            if vSpotsSelected==1
                vAllStatistics = vSpots.GetStatistics;
                vSpotStatNames = cell(vAllStatistics.mNames);
                vSpotStatValues = vAllStatistics.mValues;
                vSpotIndex=strmatch('Intensity Min', vSpotStatNames);
                vAllMinDist = vSpotStatValues(vSpotIndex,:);
            else
                vAllStatistics = vSurfaces.GetStatistics;
                vSurfaceStatNames = cell(vAllStatistics.mNames);
                vSurfaceStatValues = vAllStatistics.mValues;
                vSurfaceIndex=strmatch('Intensity Min', vSurfaceStatNames);
                vAllMinDist = vSurfaceStatValues(vSurfaceIndex,:);
            end
                                    
            %Separate out the new Distance Transform channel values
            [NumberofObjectsperTimepoint, forgetMeBins] = hist(vAllTimeIndices,0:max(vAllTimeIndices)+1); %Number of objects per timepoint
            NumberofObjectsperTimepoint = NumberofObjectsperTimepoint';
            %NumberofObjectsperTimepoint = histcounts(vAllTimeIndices)'; %Number of objects per timepoint
            vAllTimeIndices=vAllTimeIndices+1;
            %Select the last channel for IntenistyMin, this represents distance
            %transform channel
            vMinDist=vAllMinDist(end-(sum(NumberofObjectsperTimepoint)-1):end,:);
            
            %Calculate the Contact intervals for each timepoint
            if aSizeT>1
                if vSpotsSelected==1
                    t(1,:) = datetime(cell(vSpots.GetTimePoint(0)),...
                        'Format','yyyy-MM-dd HH:mm:ss.SSS');
                    tInt(1,:)=datevec(between(t(1),t(1)));
                    for w=1:aSizeT-1
                        t(w+1,:) = datetime(cell(vSpots.GetTimePoint(w)),...
                            'Format','yyyy-MM-dd HH:mm:ss.SSS');
                        tInt(w+1,:)=datevec(between(t(w),t(w+1)));
                        vContactInterval(w,:)=(tInt(w,6)+tInt(w+1,6))/2;
                    end
                else
                    %t(1,:) = datetime(cell(vSurfaces.GetTimePoint(0)),...
                    %    'Format','yyyy-MM-dd HH:mm:ss.SSS');
                    t = 24*60*60*datenum(char(vSurfaces.GetTimePoint(0)),'yyyy-mm-dd HH:MM:SS.FFF');
                    tInt = 0;
                    for w=1:aSizeT-1
                        %t(w+1,:) = datetime(cell(vSurfaces.GetTimePoint(w)),...
                        %    'Format','yyyy-MM-dd HH:mm:ss.SSS');
                        t(w+1,:) = 24*60*60*datenum(char(vSurfaces.GetTimePoint(w)),'yyyy-mm-dd HH:MM:SS.FFF');
                        tInt(w+1,:)=t(w+1)-t(w);
                        vContactInterval(w,:)=(tInt(w)+tInt(w+1))/2;
                    end
                end
                vContactInterval(w+1,:)=tInt(w+1)/2;
                
                clear LongestKissEventTime MeanKissEventTime TotalTrackDurationAllKissEvents TotalNumberofProlongedKissEvents TotalTrackDurationAway vPercentContactTotal
                
                %Calculate Kiss and run events
                for trackloop = 0:vtrackIDmax;
                    vSurfacesT = vtrackID == trackloop;
                    vSurfacesIndex = find(vSurfacesT);%Generate SurfaceIndex based on the logical matrix
                    vWorkingMinDist=vMinDist(vSurfacesIndex,:);%Find DIstMin for each object in track
                    NumberofContacts=sum(vWorkingMinDist<=DistanceThreshold);%Count the number of contacts that meet threshold
                    vNumberofContactsTotal=[vNumberofContactsTotal;NumberofContacts];
                    vPercentContactTotal(trackloop+1)=NumberofContacts/numel(vSurfacesIndex)*100;
                    
                    %Find the indices for contact and non-contact events
                    ContactNO=find(vWorkingMinDist>DistanceThreshold);
                    ContactYES=find(vWorkingMinDist<=DistanceThreshold);
                    %Calculate the number of events, find which are sequential
                    SeqGroups = ([0 cumsum(diff(ContactYES')~=1)])'; % find consecutive sequential contact
                    NumberofSeqGroups=max(SeqGroups)+1;%Total number
                    
                    NumberProlongedKissEvents=0;
                    TrackDurationAllKissEvents=0;
                    if ~isempty (ContactYES)
                        for q=0:NumberofSeqGroups-1
                            vSeqIndex=find(SeqGroups==q);
                            if  numel(vSeqIndex)>1
                                NumberProlongedKissEvents=NumberProlongedKissEvents+1;
                                TrackDurationAllKissEvents(q+1,:)=sum(vContactInterval(vAllTimeIndices(vSurfacesIndex(ContactYES(vSeqIndex)))));
                            else
                                TrackDurationAllKissEvents(q+1,:)=sum(vContactInterval(vAllTimeIndices(vSurfacesIndex(ContactYES(vSeqIndex)))));
                            end
                        end
                        %Number of prolonged kiss events greater than 2 timepoints
                        %Extract the Longest kiss event
                        LongestKissEventTime(trackloop+1)=max(TrackDurationAllKissEvents);
                        MeanKissEventTime(trackloop+1)=mean(TrackDurationAllKissEvents);
                        TotalTrackDurationAllKissEvents(trackloop+1)=sum(TrackDurationAllKissEvents);
                        TotalNumberofProlongedKissEvents(trackloop+1)=NumberProlongedKissEvents;
                        TotalTrackDurationAway(trackloop+1)=sum(vContactInterval(vAllTimeIndices(vSurfacesIndex([ContactNO;ContactYES]))))-sum(TrackDurationAllKissEvents);
                    else
                        LongestKissEventTime(trackloop+1)=0;
                        MeanKissEventTime(trackloop+1)=0;
                        TotalNumberofProlongedKissEvents(trackloop+1)=0;
                        TotalTrackDurationAllKissEvents(trackloop+1)=0;
                        TotalTrackDurationAway(trackloop+1)=sum(vContactInterval(vAllTimeIndices(vSurfacesIndex(ContactNO))));
                    end
                end
            else
                %when there is only one timepoint
                vSurfacesT = vtrackID == 0;
                vSurfacesIndex = find(vSurfacesT);%Generate SurfaceIndex based on the logical matrix
                vNumberofContactsTotal=sum(vMinDist<=DistanceThreshold);%Count the number of contacts that meet threshold
                vPercentContactTotal=vNumberofContactsTotal/numel(vSurfacesIndex)*100;
                TotalNumberofProlongedKissEvents=0;
            end
            
            if vSpotsSelected==1
                %Add new statistic to Spots
                vInd=1:size(vAllIds);
                vIds=vAllIds;
                vUnits(vInd) = {'um'};
                vFactors(vInd) = {'Spot'};
                vFactors(2, vInd) = num2cell(vAllTimeIndices);
                vFactors(2, vInd) = cellfun(@num2str, vFactors(2, vInd), 'UniformOutput', false);
                vFactorNames = {'Category','Time'};
                vNames(vInd) = {sprintf(' Distance to %s',char(vTargetSurface.GetName))};
                vSpots.AddStatistics(vNames, vMinDist, vUnits, vFactors, vFactorNames, vIds);
                
                %Overall Statistics
                for i=1:aSizeT
                    OverallNumberOfContactsperTimpoint(i)=sum(vMinDist(vAllTimeIndices==i)<=DistanceThreshold);
                    OverallTotalNumberOfSurfacesperTimpoint(i)=sum(vMinDist(vAllTimeIndices==i)>=0);
                end
                
                PercentageContactsperTimpoint=round(OverallNumberOfContactsperTimpoint./OverallTotalNumberOfSurfacesperTimpoint*100,2);
                OverallNumberOfProlongedContacts=TotalNumberofProlongedKissEvents;
                
                clear vInd vIds vUnits vFactors vNames
                vInd=1:aSizeT;
                vIds(vInd)=0;
                vUnits(vInd) = {'%'};%{ char(vImarisApplication.GetDataSet.GetUnit) };
                Indices=1:aSizeT;
                vFactors(vInd) = {'Overall'};
                vFactors(2, vInd) = num2cell(Indices);
                vFactors(2, vInd) = cellfun(@num2str, vFactors(2, vInd), 'UniformOutput', false);
                vFactorNames = {'Overall','Time'};
                vNames(vInd) = {sprintf(' Percent Surface Contacts per Timepoint with %s',char(vTargetSurface.GetName))};
                vSpots.AddStatistics(vNames, PercentageContactsperTimpoint', vUnits, vFactors, vFactorNames, vIds);
                vUnits(vInd) = {''};
                vNames(vInd) = {sprintf(' Number of Contacts per Timepoint with %s',char(vTargetSurface.GetName))};
                vSpots.AddStatistics(vNames, OverallNumberOfContactsperTimpoint', vUnits, vFactors, vFactorNames, vIds);
                
                %Set Track Statistics
                vIndT=1:vtrackIDmax+1;%Total number of tracks
                vIdsT=0:vtrackIDmax;%Total number from tracks starting at 0
                vIdsT=vIdsT+1000000000;%Conversion to Tracks reported by Imaris
                vUnitsT(vIndT) = {'sec'};
                vFactorsT(vIndT) = {'Track'};
                
                if isequal (qNumberofContacts,'YES')
                    vNamesT(vIndT) = {sprintf('Track number of contacts with %s',char(vTargetSurface.GetName))};
                    vFactorNamesT = {'Category'};
                    vSpots.AddStatistics(vNamesT, vNumberofContactsTotal, vUnitsT, vFactorsT, vFactorNamesT, vIdsT);
                end
                if isequal (qNumberofProlongedContacts,'YES') && aSizeT>1
                    vNamesT(vIndT) = {sprintf('Track number prolonged contact events with %s',char(vTargetSurface.GetName))};
                    vUnitsT(vIndT) = {''};
                    vSpots.AddStatistics(vNamesT, TotalNumberofProlongedKissEvents, vUnitsT, vFactorsT, vFactorNamesT, vIdsT);
                end
                if isequal (qPercentNumberofContacts,'YES')
                    vNamesT(vIndT) = {sprintf('Track percent surface contact with %s',char(vTargetSurface.GetName))};
                    vUnitsT(vIndT) = {'%'};
                    vSpots.AddStatistics(vNamesT, vPercentContactTotal, vUnitsT, vFactorsT, vFactorNamesT, vIdsT);
                end
                if isequal (qTotalContactTime,'YES') && aSizeT>1
                    vNamesT(vIndT) = {sprintf('Track total time in contact with %s',char(vTargetSurface.GetName))};
                    vUnitsT(vIndT) = {'sec'};
                    vSpots.AddStatistics(vNamesT, TotalTrackDurationAllKissEvents, vUnitsT, vFactorsT, vFactorNamesT, vIdsT);
                end
                if isequal (qTotalTrackDurationAway,'YES') && aSizeT>1
                    vNamesT(vIndT) = {sprintf('Track total time without contact with %s',char(vTargetSurface.GetName))};
                    vUnitsT(vIndT) = {'sec'};
                    vSpots.AddStatistics(vNamesT, TotalTrackDurationAway, vUnitsT, vFactorsT, vFactorNamesT, vIdsT);
                end
                if isequal (qLongestContactEvent,'YES') && aSizeT>1
                    vNamesT(vIndT) = {sprintf('Track longest contact event with %s',char(vTargetSurface.GetName))};
                    vUnitsT(vIndT) = {'sec'};
                    vSpots.AddStatistics(vNamesT, LongestKissEventTime, vUnitsT, vFactorsT, vFactorNamesT, vIdsT);
                end
                if isequal (qMeanContactEvent,'YES') && aSizeT>1
                    vNamesT(vIndT) = {sprintf('Track mean length contact event with %s',char(vTargetSurface.GetName))};
                    vUnitsT(vIndT) = {'sec'};
                    vSpots.AddStatistics(vNamesT, MeanKissEventTime, vUnitsT, vFactorsT, vFactorNamesT, vIdsT);
                end
                
                %Rename new surface to Surpass Scene
                vSpots.SetName(sprintf('Analyzed Distance threshold - %s',char(vSpots.GetName)));
                vImarisApplication.GetSurpassScene.AddChild(vSpots, -1);
                
                
            else
                clear vNames vUnits vFactors vFactorNames vIds vUnitsT vFactorsT vNamesT
                %Add new statistic to Surfaces
                vInd=1:size(vAllIds);
                vIds=vAllIds;
                vUnits(vInd) = {'um'};
                vFactors(vInd) = {'Surface'};
                vFactors(2, vInd) = num2cell(vAllTimeIndices);
                vFactors(2, vInd) = cellfun(@num2str, vFactors(2, vInd), 'UniformOutput', false);
                vFactorNames = {'Category','Time'};
                vNames(vInd) = {sprintf(' Distance to %s',char(vTargetSurface.GetName))};
                vSurfaces.AddStatistics(vNames, vMinDist, vUnits, vFactors, vFactorNames, vIds);
                
                
                %Overall Statistics
                for i=1:aSizeT
                    OverallNumberOfContactsperTimpoint(i)=sum(vMinDist(vAllTimeIndices==i)<=DistanceThreshold);
                    OverallTotalNumberOfSurfacesperTimpoint(i)=sum(vMinDist(vAllTimeIndices==i)>=0);
                end
                
                
                PercentageContactsperTimpoint=round(OverallNumberOfContactsperTimpoint./OverallTotalNumberOfSurfacesperTimpoint*100*100)/100;
                OverallNumberOfProlongedContacts=TotalNumberofProlongedKissEvents;
                
                clear vInd vIds vUnits vFactors vNames 
                vInd=1:aSizeT;
                vIds(vInd)=0;
                vUnits(vInd) = {'%'};%{ char(vImarisApplication.GetDataSet.GetUnit) };
                Indices=1:aSizeT;
                vFactors(vInd) = {'Overall'};
                vFactors(2, vInd) = num2cell(Indices);
                vFactors(2, vInd) = cellfun(@num2str, vFactors(2, vInd), 'UniformOutput', false);
                vFactorNames = {'Overall','Time'};
                vNames(vInd) = {sprintf('Track percent Surface Contacts per Timepoint with %s',char(vTargetSurface.GetName))};
                vSurfaces.AddStatistics(vNames, PercentageContactsperTimpoint', vUnits, vFactors, vFactorNames, vIds);
                vUnits(vInd) = {''};
                vNames(vInd) = {sprintf('Track number of Contacts per Timepoint with %s',char(vTargetSurface.GetName))};
                vSurfaces.AddStatistics(vNames, OverallNumberOfContactsperTimpoint', vUnits, vFactors, vFactorNames, vIds);
                
                
                
                
                %Set Track Statistics
                vIndT=1:vtrackIDmax+1;%Total number of tracks
                vIdsT=0:vtrackIDmax;%Total number from tracks starting at 0
                vIdsT=vIdsT+1000000000;%Conversion to Tracks reported by Imaris
                vUnitsT(vIndT) = {'sec'};
                vFactorsT(vIndT) = {'Track'};
                
                if isequal (qNumberofContacts,'YES')
                    vNamesT(vIndT) = {sprintf('Track Number of contacts with %s',char(vTargetSurface.GetName))};
                    vUnitsT(vIndT) = {''};                    
                    vFactorNamesT = {'Category'};
                    vSurfaces.AddStatistics(vNamesT, vNumberofContactsTotal, vUnitsT, vFactorsT, vFactorNamesT, vIdsT);
                end
                if isequal (qNumberofProlongedContacts,'YES') && aSizeT>1
                    vNamesT(vIndT) = {sprintf('Track Number prolonged contact events with %s',char(vTargetSurface.GetName))};
                    vUnitsT(vIndT) = {''};
                    vSurfaces.AddStatistics(vNamesT, TotalNumberofProlongedKissEvents, vUnitsT, vFactorsT, vFactorNamesT, vIdsT);
                end
                if isequal (qPercentNumberofContacts,'YES')
                    vNamesT(vIndT) = {sprintf('Track Percent Surface contact with %s',char(vTargetSurface.GetName))};
                    vUnitsT(vIndT) = {'%'};
                    vSurfaces.AddStatistics(vNamesT, vPercentContactTotal, vUnitsT, vFactorsT, vFactorNamesT, vIdsT);
                end
                if isequal (qTotalContactTime,'YES') && aSizeT>1
                    vNamesT(vIndT) = {sprintf('Track Total time in contact with %s',char(vTargetSurface.GetName))};
                    vUnitsT(vIndT) = {'sec'};
                    vSurfaces.AddStatistics(vNamesT, TotalTrackDurationAllKissEvents, vUnitsT, vFactorsT, vFactorNamesT, vIdsT);
                end
                if isequal (qTotalTrackDurationAway,'YES') && aSizeT>1
                    vNamesT(vIndT) = {sprintf('Track Total Time without Contact with %s',char(vTargetSurface.GetName))};
                    vUnitsT(vIndT) = {'sec'};
                    vSurfaces.AddStatistics(vNamesT, TotalTrackDurationAway, vUnitsT, vFactorsT, vFactorNamesT, vIdsT);
                end
                if isequal (qLongestContactEvent,'YES') && aSizeT>1
                    vNamesT(vIndT) = {sprintf('Track Longest contact event with %s',char(vTargetSurface.GetName))};
                    vUnitsT(vIndT) = {'sec'};
                    vSurfaces.AddStatistics(vNamesT, LongestKissEventTime, vUnitsT, vFactorsT, vFactorNamesT, vIdsT);
                end
                if isequal (qMeanContactEvent,'YES') && aSizeT>1
                    vNamesT(vIndT) = {sprintf('Track Mean Length contact event with %s',char(vTargetSurface.GetName))};
                    vUnitsT(vIndT) = {'sec'};
                    vSurfaces.AddStatistics(vNamesT, MeanKissEventTime, vUnitsT, vFactorsT, vFactorNamesT, vIdsT);
                end
                
                %Rename new surface to Surpass Scene
                vSurfaces.SetName(sprintf('Analyzed Distance threshold - %s',char(vSurfaces.GetName)));
                vImarisApplication.GetSurpassScene.AddChild(vSurfaces, -1);
            end
            
        end        
    end
end

end


