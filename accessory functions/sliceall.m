function bwims = sliceall(ims,thresh)
  
sz = size(ims);

bwims = logical(zeros(size(ims)));

for i = 1:sz(3)
%  fprintf('%d ',i);
  im = ims(:,:,i);
  bwims(:,:,i) = im2bw(im, thresh);
  
end;

%fprintf('\n');