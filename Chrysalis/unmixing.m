function vol_unmixed = unmixing(vol,spectra)
% vol_unmixed_iso = unmixing(vol,spectra)
%
%   Performs linear unmixing by solving the system of equations vol = A H
%   where H is the spectral matrix (see below) and vol is the input image
%   whose shape is (.. x .. x N), where N is the number of channels.
%
%   vol     is the input image (.. x .. x N), where N is the number of
%           channels. The image can be any number of dimensions (>1), as 
%           long as the channels are iterated in the last dimension.
%
%   spectra   is NxM, where N is the number of channels and M is the number 
%             of dyes/fluorophores
%
%   vol_unmixed     is the unmixed image, of size (.. x .. x M), where M is 
%                   the number of dyes/fluorophores
%
    nch = size(spectra,1);

    % Now 'vol' is in XYZC format
    Y = reshape(vol,numel(vol)/nch,nch)';
    
    %[Ac, H, xts, im_out] = NMF_ML(single(Y),m,spectra,single(Y));
    
    %H = nnls(spectra,single(Y),single(Y));
        
    fprintf('Unmixing...');
    H = spectra \ single(Y);
    H(H<0)=0;
    fprintf('done.\n');
    
    vol_unmixed = reshape(H',size(vol));
end