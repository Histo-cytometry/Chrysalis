function writeBigDataXML(filename_base,hypervolume,dimensionorder,varargin)

%% Parse inputs
p = inputParser;
addRequired(p,'filename_base',@ischar);
addRequired(p,'hypervolume',@isnumeric);
addRequired(p,'dimensionorder',@ischar);
addOptional(p,'VoxelSize',[1 1 1],@(x) isnumeric(x) && all(size(x)==[1 3]));
addOptional(p,'Units','micron',@(x) ischar(x));
addOptional(p,'Version','0.2',@(x) ischar(x));
addOptional(p,'DeflateLevel',0,@(x) isnumeric(x) && x<=9 && x>=0);
addOptional(p,'ChunkSize',[256 256 16],@(x) isnumeric(x));
parse(p,filename_base,hypervolume,dimensionorder,varargin{:})

%% Parameter extraction
voxelSize = p.Results.VoxelSize;
bdversion = p.Results.Version;
deflevel = p.Results.DeflateLevel;
chunkSize = p.Results.ChunkSize;
units = p.Results.Units;

transformMatrix = [diag(voxelSize) zeros(3,1)];
%transformMatrix = [eye(3) zeros(3,1)];

[~, fbase, ext] = fileparts(filename_base);
fbase = [fbase ext];

xmlfile = [filename_base '.xml'];
h5file = [filename_base '.h5'];

if length(size(hypervolume))~=length(dimensionorder)
    error(['Dimension spec ' dimensionorder ' does not match actual dimensionality of the data (' num2str(size(hypervolume)) ')']);
end

dims = size(hypervolume);

if isempty(find(lower(dimensionorder)=='t', 1))
    dimensionorder = [dimensionorder 't'];
    dims = [dims 1];
end

chunkSize = min(cat(1,chunkSize,dims(1:3)));

tdim = find(lower(dimensionorder)=='t');
cdim = find(lower(dimensionorder)=='c');

nt = dims(tdim);
nc = dims(cdim);

hypervolume = permute(hypervolume,[1 2 3 cdim tdim]);

%% Start creating XML
docNode = com.mathworks.xml.XMLUtils.createDocument('SpimData');
docRootNode = docNode.getDocumentElement;
docRootNode.setAttribute('version',bdversion);

bp = docNode.createElement('BasePath');
bp.setAttribute('type','relative');
bp.appendChild(docNode.createTextNode('.'));

docRootNode.appendChild(bp);

sd = docNode.createElement('SequenceDescription');
il = docNode.createElement('ImageLoader');
il.setAttribute('format','bdv.hdf5');

h5 = docNode.createElement('hdf5');
h5.setAttribute('type','relative');
h5.appendChild(docNode.createTextNode([fbase '.h5']));

il.appendChild(h5);
sd.appendChild(il);

vs = docNode.createElement('ViewSetups');
for ic = 0:(nc-1)
    vx = docNode.createElement('ViewSetup');
    id = docNode.createElement('id');
    id.appendChild(docNode.createTextNode(num2str(ic)));
    vx.appendChild(id);
    name = docNode.createElement('name');
    name.appendChild(docNode.createTextNode(['channel ' num2str(ic+1)]));
    vx.appendChild(name);
    el = docNode.createElement('size');
    el.appendChild(docNode.createTextNode(num2str(dims(1:3))));
    vx.appendChild(el);
    vxs = docNode.createElement('voxelSize');
    el = docNode.createElement('unit');
    el.appendChild(docNode.createTextNode(units));
    vxs.appendChild(el);    
    el = docNode.createElement('size');
    el.appendChild(docNode.createTextNode(num2str(voxelSize)));
    vxs.appendChild(el);    
    vx.appendChild(vxs);
    
    el = docNode.createElement('attributes');
    ell = docNode.createElement('channel');
    ell.appendChild(docNode.createTextNode(num2str(ic+1)));
    el.appendChild(ell);
    vx.appendChild(el);

    vs.appendChild(vx);
end
att = docNode.createElement('Attributes');
att.setAttribute('name','channel');
for ic = 1:nc
    ch = docNode.createElement('Channel');
    id = docNode.createElement('id');
    id.appendChild(docNode.createTextNode(num2str(ic)));
    ch.appendChild(id);
    nm = docNode.createElement('id');
    nm.appendChild(docNode.createTextNode(num2str(ic)));
    ch.appendChild(nm);
    att.appendChild(ch);
end
vs.appendChild(att);
sd.appendChild(vs);

tp = docNode.createElement('Timepoints');
tp.setAttribute('type','range');
el = docNode.createElement('first');
el.appendChild(docNode.createTextNode('0'));
tp.appendChild(el);
el = docNode.createElement('last');
el.appendChild(docNode.createTextNode(num2str(nt-1)));
tp.appendChild(el);
sd.appendChild(tp);

docRootNode.appendChild(sd);

vrs = docNode.createElement('ViewRegistrations');
rt = docNode.createElement('ReferenceTimepoint');
rt.appendChild(docNode.createTextNode('0'));
vrs.appendChild(rt);
for it = 0:(nt-1)
    for ic = 0:(nc-1)
        vr = docNode.createElement('ViewRegistration');
        vr.setAttribute('timepoint',num2str(it));
        vr.setAttribute('setup',num2str(ic));
        vt = docNode.createElement('ViewTransform');
        vt.setAttribute('type','affine');

        af = docNode.createElement('affine');
        s = sprintf('%f ',transformMatrix');
        af.appendChild(docNode.createTextNode(s(1:end-1)));
        vt.appendChild(af);

        vr.appendChild(vt);
        vrs.appendChild(vr);
    end
end
docRootNode.appendChild(vrs);


xmlwrite(xmlfile,docNode);
%type(xmlfile);


%% Write HDF5 
for ic=0:(nc-1)
    ress = '/s%02i/resolutions';
    h5create(h5file,sprintf(ress,ic),[3 1],'Datatype','uint16');
    h5write(h5file,sprintf(ress,ic),uint16([1;1;1]));
    
    subs = '/s%02i/subdivisions';
    h5create(h5file,sprintf(subs,ic),[3 1],'Datatype','uint16');
    h5write(h5file,sprintf(subs,ic),uint16(chunkSize'));
end

sf = '/t%05i/s%02i/0/cells';
for it=0:(nt-1)
    for ic=0:(nc-1)
        s = sprintf(sf,it,ic);
        h5create(h5file,s,dims([1,2,3]),'Datatype','uint16','Deflate',deflevel,'ChunkSize',chunkSize);
        slice = zeros(dims(1:3),'uint16');
        hs = hypervolume(:,:,:,ic+1,it+1);
        slice(:) = uint16(hs(:));        
        h5write(h5file,s,slice);
    end
end
