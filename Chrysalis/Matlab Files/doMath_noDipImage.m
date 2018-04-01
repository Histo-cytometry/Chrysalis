function final = doMath(include,exclude,basechannel,vol_unmixed_iso)
fprintf('Creating New Channel...');

skipped = 10;

siz = size(vol_unmixed_iso);
ndims = length(siz);

m = true(prod(siz(1:ndims-1)),1);
vol_2Dp = reshape(vol_unmixed_iso,prod(siz(1:ndims-1)),siz(end));
for i_include = include
    %[t, tt] = threshold(vol_2Dp(1:skipped:end,i_include),algo);
    tmp_in = vol_2Dp(1:skipped:end,i_include);
    tt = graythresh(tmp_in);
    m = m & vol_2Dp(:,i_include)>tt;
end
for i_exclude = exclude
    %[t, tt] = threshold(vol_2Dp(1:skipped:end,i_exclude),'triangle');
    [H, bins] = histcounts(single(vol_2Dp(1:skipped:end,i_exclude)));
    t = our_triangle(H,bins);
    m = m & vol_2Dp(:,i_exclude)<t;
end

baseImage = vol_2Dp(:,basechannel);

newChannel = baseImage;
newChannel(~m) = 0;
newChannel = single(newChannel);
newChannel = reshape(newChannel,siz(1:end-1));

fprintf('done.\n');

final = cat(ndims,vol_unmixed_iso,newChannel);

end