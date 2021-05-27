%{
Provide the exact directory and file location and the file name in line 25.  

The following two commanda will allow you to obtain the file location:
[file,path] = uigetfile; file_location=cat(2,path,file).  Copy the file
location and paste within the quotes in line 25.

To perform concequtive processing of multiple files wild characcter can be 
added at specific locations.  For example in file name cs3c-1_w1DIC Camera_s6.tif 
replacing 6 to the right of _s with a *will allow processing of all files 
for different positions.

The program assumes that the file names consists of four parts - as in
descripter_wavelength_position.tif, for example, cs1-1_w1DIC Camera_s1.tif . 
In this example, the string left to the first underscore is the descriptor fo 
your experiment, between the two underscores is the wavelength, and to the 
right of the second underscore but befor the suffix .tif is the position.  
The last element is the file type .tif. 

Set paths in the MATLAB by HOME/Set Path
In line 26 provide the directory where the .mat file with the cell boundaries 
will be saved.  In line 27 provide the directory where the randomley colored 
cells will be saved. 
%}
files = dir('C:\Users\imaging\Desktop\Test_10-1-19\compressed z stacks\cs1-2_w3Rhodamine Camera_s*_Simple Segmentation.tif');
save_location_cell_boundary_files='C:\Users\imaging\Desktop\Test_10-1-19\cell boundary files';
save_location_matlab_figures='C:\Users\imaging\Desktop\Test_10-1-19\saved matlab figures';


for k=1:size(files,1);
filename1 = files(k).name;
filename2 = strrep(filename1, '_Simple Segmentation', '');

I=imread(filename1);%I=imresize(I,2);
I2=imread(filename2);
I2=im2double(I2);
%imtool(I2); p1 = input('image1_low ');q1 = input('image1_high ');
[level,EM] = graythresh(I);
bw=im2bw(I, level);
bw=imcomplement(bw);
%smooth
seD = strel('diamond',3);
bwerode = imerode(bw,seD);
%fill holes
bwfill = imfill(bwerode, 'holes');
%remove small areas
[lab1,n1] = bwlabel(bwfill);
s = regionprops(lab1,'Area');
areas1 = [s.Area];
bwselect = ismember(lab1,find(areas1 > 3000));
%plot boudaries over cells
[cell_boundaries] = bwboundaries(bwselect);
a =stretchlim(I2);
figure(1);imshow(I2, [a(1) a(2)]);hold on;
for i =1:length(cell_boundaries);
plot(cell_boundaries{i}(:,2),cell_boundaries{i}(:,1),'b', 'LineWidth', 2);
end
%draw walls
n = input('How many walls would you like to draw? ');
for i=1:n;
hFH = imfreehand();
clear xy xCoordinates yCoordinates newXSamplePoints pp smoothedXCoordinates smoothedY; 
xy = hFH.getPosition;
delete(hFH);
xCoordinates = xy(:, 1);yCoordinates = xy(:, 2);
%binaryImage = zeros(size(bwselect));
%for k = 1 : length(xy)
  %binaryImage(int32(yCoordinates(k)), int32(xCoordinates(k))) = true;
%end
numberOfKnots = length(xCoordinates);
samplingRateIncrease = 30;
newXSamplePoints = linspace(1, numberOfKnots, numberOfKnots * samplingRateIncrease);
yy = [0, xCoordinates', 0; 1, yCoordinates', 1];
pp = spline(1:numberOfKnots, yy); 
smoothedY = ppval(pp, newXSamplePoints);
smoothedXCoordinates = smoothedY(1, :);
smoothedYCoordinates = smoothedY(2, :);
plot(smoothedXCoordinates, smoothedYCoordinates, 'r','LineWidth', 2);
wall{i} = [smoothedXCoordinates' smoothedYCoordinates'];
end
%mask_cells = roipoly(bwselect,(wall{i}(:,1)), (wall{i}(:,2)));
binaryImage = true(size(bwselect));
for i =1:n
%linearIndexes = sub2ind(size(bwselect), int32(smoothedXCoordinates), int32(smoothedYCoordinates));
linearIndexes = sub2ind(size(bwselect), int32(wall{i}(:,2)), int32(wall{i}(:,1)));
binaryImage(linearIndexes) = false;
end

%combine with selected cells
bwsegregate = bwselect&binaryImage;
bwnoborder = imclearborder(bwsegregate, 4);

%widen the walls
seD = strel('diamond',1);
bwnoborder=imerode(bwnoborder, seD);
%remove small objects

bw_ac=activecontour(I,bwnoborder,25,'edge');
[lab1,n1] = bwlabel(bw_ac);
s = regionprops(lab1,'Area');
areas1 = [s.Area];
bw_large = ismember(lab1,find(areas1 > 3000));

%count cells
[lab1,n1] = bwlabel(bw_large);
lrgb = label2rgb(lab1, 'jet', 'w', 'shuffle');
mask_cells=bw_large;
%mask_cells_bw=im2bw(mask_cells);
[cell_boundaries] = bwboundaries(mask_cells)';

filename3 = replaceBetween(filename2,'_','_','wavelength');
filename3=replace(filename3,'.tif','.mat');
f=fullfile(save_location_cell_boundary_files, filename3);

filename3=replace(filename3,'.mat','.fig');
figure('name',filename3); imshow(lrgb);
savefile = cat(2, filename3);

m=input('Do you want to save data, y/n [Y]:','s');
if m=='y';

save(f, 'cell_boundaries');
g=fullfile(save_location_matlab_figures, savefile);
saveas(gcf, cat(2,g), 'fig');

else
end
clearvars -except files save_location_cell_boundary_files save_location_matlab_figures;
end