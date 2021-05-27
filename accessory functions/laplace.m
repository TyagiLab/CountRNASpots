function outims = laplace(ims)

createfilter;

  
sz = size(ims);

outims = zeros(sz);

fprintf('Processing image: ');

for i = 1:sz(3)
  fprintf('%d ',i);
  outims(:,:,i) = imfilter(ims(:,:,i),h3);
end;

fprintf('\n');