%{
Provide the exact directory location and the file name in line 21.  A wild
characcter can be added at specific locations for concequtive processing
of multiple files.  For example in file name cs3c-1_w1DIC Camera_s6.tif 
replacing 6 to the right of _s with a *will allow processing of all files 
for different positions.  The following two commanda will allow you to obtain 
the file location:
[file,path] = uigetfile; file_location=cat(2,path,file).  Copy teh file
location and paste within the quotes in line 1.

The program assumes that the file names consists of four parts - as in
descripter_wavelength_position.tif, for example, cs1-1_w1DIC Camera_s1.tif . In
this example, the string left to the first underscore is the descriptor fo your experiment,
between the two underscores is the wavelength, and to the right of the
second underscore but befor the suffix .tif is the position.  The last element is the file type .tif. 

Set paths in the MATLAB by HOME/Set Path.  Provide the wavelengths in 
lines 22 and 23.  Provide the directory where
the results should be saved (as a .csv file) in line 24.
%}
file_location='C:\Users\imaging\Desktop\Test_10_2_19\cs1-2_w1DIC Camera_s2.TIF';
DIC_name='w1DIC Camera'; %wavelength portion of DIC file name, text between two underscores
DAPI_name='w2DAPI Camera'; %wavelength portion of DAPI file name, text between two underscores
save_location='C:\Users\imaging\Desktop\Test_10_2_19\cell boundary files'; %where cell boundaries will be saved
files = dir(file_location);
for k=1:size(files,1)
close all;
filename = files(k).name;
IDIC=imread(filename);
filename2=strrep(filename, DIC_name,DAPI_name);
IDAPI = imread(filename2);
I1=im2double(IDIC);
I2=im2double(IDAPI);
I1=imadjust(I1, stretchlim(I1),[]);
I2=imadjust(I2,[min(I2(:)) max(I2(:))]);
green = I1;
blue = I1+I2;
red = I1;
RGB= cat(3,red,green,blue);imshow(RGB);

n = input('How many walls would you like to draw? ');
figure(1);

imshow(RGB);
hold on;

binaryImage = zeros(size(IDIC));
for i=1:n
    hFH = imfreehand('Closed',false);
    a = i*hFH.createMask;
    binaryImage = func_binaryimage(a,binaryImage);
    b = logical(a);
    r = regionprops(b,'Centroid');
    r = r(1).Centroid;
    text(r(1),r(2),['\fontsize{25}', '\color{cyan}' num2str(i)]);
end

for i = 1:n
    temp = binaryImage == i;
    wall{i} = bwboundaries(temp);
    end
for i=1:size(wall,2)
           area_cell(i)=polyarea(wall{i}{1}(:,2),wall{i}{1}(:,1));
        if area_cell(i) < 4000
         wall{i} =[];
        end
        end
empties = find(cellfun(@isempty,wall)); 
wall(empties) = [];

for i=1:size(wall,2);
    cell_boundaries{i}=wall{1,i}{1,1};
end


filename3 = replaceBetween(filename,'_','_','wavelength');
filename4=replace(filename3,extractAfter(filename3,'.'),'mat');
f=fullfile(save_location, filename4);
save(f, 'cell_boundaries');
%close all;
end
%clearvars -except files file_location DIC_name DAPI_name save_location;
%---
function output = func_binaryimage(mask_image,current_image)
    
    output =  current_image + mask_image;
    nmb_wall = max(mask_image(:));    

    temp_image = output>nmb_wall;
    output = output-nmb_wall*temp_image;

    temp = imfill(output,'holes');
    temp = logical(temp - (output));
    output = output+temp*nmb_wall;
end
