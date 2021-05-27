%{
Provide the exact directory location and the file names in lines 20 and 21. 
The following two commands will allow you to obtain the file location - 
[file,path] = uigetfile;file_location=cat(2,path,file);

The program assumes that the file names consists of four parts - as in
descripter_wavelength_position.tif, for example, cs1-1_w1DIC Camera_s1.tif . 
In this example, the string left to the first underscore is the descriptor fo 
your experiment, between the two underscores is the wavelength, and to the 
right of the second underscore but befor the suffix .tif is the position.  
The last element is the file type .tif.

In line 22 provide the directory where the figue with circles drawn around the spots are saved. 
In line 23 provide the directory where the results should be saved (as a .csv file).  
Columns in the saved .csv files are: filename, cell number, number of molecules in in 
channel1, number of molecules in channel2, threhold used for channe l 1, and threhold 
used for channel 2.  Spots counts are saved in a .csv file at location
indicated below.
%}
file_location1 = dir('C:\Users\imaging\Desktop\Test_10-1-19\cs1-2_w4Cy5 Camera_s1.TIF');%channel1
file_location2 = dir('C:\Users\imaging\Desktop\Test_10-1-19\cs1-2_w4Cy5 Camera_s1.TIF');%channel2
save_location_matlab_figures='C:\Users\imaging\Desktop\Test_10-1-19\saved matlab figures';%location where to save the figure
save_location_csv='C:\Users\imaging\Desktop\Test_10-1-19\particle_numbers.csv'; %location where to save the spot counts

filename1=file_location1(1).name;
I=imread(filename1,8);
info = imfinfo(filename1);
ims=zeros([size(I),(numel(info))]);
for k=1:1:(numel(info)); 
        ims(:,:,k)=imread(filename1,(k)); 
    end;
imsd = medianfilter(double(ims));clear ims;
lapims1 = laplace(imsd); clear imsd;
lapims1 = lapims1/max(lapims1(:));
im1 = max(lapims1,[],3);

filename2=file_location2(1).name;
I2=imread(filename2,8);
info2 = imfinfo(filename2);
ims2=zeros([size(I2),(numel(info2))]);
for k=1:1:(numel(info2)); 
        ims2(:,:,k)=imread(filename2,(k)); 
    end;
imsd2 = medianfilter(double(ims2));clear ims2;
lapims2 = laplace(imsd2); clear imsd2;
lapims2 = lapims2/max(lapims2(:));
im2 = max(lapims2,[],3);

%Get threholds
fprintf('Draw rectangle with mouse for thresholding                %g\n');
figure(1);
im1_adjust=imadjust(im1, stretchlim(im1),[]); imshow(im1_adjust);
R = getrect;
test = imcrop(im1,R);
figure(2);
surf(test);
threshx = input('Threshold? ');
L = sliceall(lapims1,threshx);
clear lapims1;
fprintf('Draw rectangle with mouse for thresholding                %g\n');
figure(3);
im2_adjust=imadjust(im2, stretchlim(im2),[]); imshow(im2_adjust);
R = getrect;
test = imcrop(im2,R);
figure(4);
surf(test);
threshy = input('Threshold? ');
K = sliceall(lapims2,threshy);
clear lapims2;

[lab1,n] = bwlabeln(L);
s = regionprops(lab1,'Area');
areas = [s.Area];
smallestp=find(areas > 10);
largestp=find(areas < 300);
averagep=intersect(smallestp,largestp);

bw1 = ismember(lab1,averagep);
[lab1,n] = bwlabeln(bw1);
s1 = regionprops(lab1,'Centroid');
centers1 = cat(1,s1.Centroid);

[lab2,n] = bwlabeln(K);
s = regionprops(lab2,'Area');
areas = [s.Area];
clear ims; clear imsd;clear lab1;
smallestp=find(areas > 10);
largestp=find(areas < 300);
averagep=intersect(smallestp,largestp);

bw2 = ismember(lab2,averagep);
[lab2,n] = bwlabeln(bw2);
s1 = regionprops(lab2,'Centroid');
centers2 = cat(1,s1.Centroid);

figure(5);
green = im1_adjust;
red = im2_adjust;
blue = zeros(size(im1));
RGB= cat(3,red,green,blue);
hold off;
imshow(RGB);
hold on;

filename3 = replaceBetween(filename1,'_','_','wavelength');
load(cat(2,extractBefore(filename3,'.'),'.mat'));

centers1x_withincell = cell(1,size(cell_boundaries,1));centers1y_withincell = cell(1,size(cell_boundaries,1));
centers2x_withincell = cell(1,size(cell_boundaries,1));centers2y_withincell = cell(1,size(cell_boundaries,1));
particle_numbers=zeros(size(cell_boundaries,1),5);

for i = 1:size(cell_boundaries,2);
    cell_boundaries_1 = cell_boundaries{i};
    
    if size(centers1,1) == 0; particle_numbers(i,2)=0;
    else
        withincell_centers1 = inpolygon(centers1(:,1),centers1(:,2),cell_boundaries_1(:,2),cell_boundaries_1(:,1));
        centers1x = centers1(:,1); centers1y = centers1(:,2);
        centers1x_withincell{1,i} = centers1x(withincell_centers1);
        centers1y_withincell{1,i} = centers1y(withincell_centers1);
        particle_numbers(i,2)=size(centers1x_withincell{1,i},1);
        plot(centers1x_withincell{1,i},centers1y_withincell{1,i}, 'go' ,'markersize',10);
    end
    
    
    if size(centers2,1) == 0; particle_numbers(i,3)=0;
    else
        withincell_centers2 = inpolygon(centers2(:,1),centers2(:,2),cell_boundaries_1(:,2),cell_boundaries_1(:,1));
        centers2x = centers2(:,1); centers2y = centers2(:,2);
        centers2x_withincell{1,i} = centers2x(withincell_centers2);
        centers2y_withincell{1,i} = centers2y(withincell_centers2);
        particle_numbers(i,3)=size(centers2x_withincell{1,i},1);
        plot(centers2x_withincell{1,i},centers2y_withincell{1,i}, 'ro' ,'markersize',10);
    end
    particle_numbers(i,1)=i;
    particle_numbers(i,4)=threshx;
    particle_numbers(i,5)=threshy;
    plot(cell_boundaries_1(:,2),cell_boundaries_1(:,1),'b', 'LineWidth', 2);
     text(mean(cell_boundaries_1(:,2)), mean(cell_boundaries_1(:,1)), ['\fontsize{25}', '\color{cyan}' num2str(i)]);
end

m=input('Do you want to save data, y/n [Y]:','s');
if m=='y';
    savefile = cat(2, filename1);
g=fullfile(save_location_matlab_figures, savefile);
saveas(gcf, cat(2,g, '.fig'), 'fig');
dlmwrite(save_location_csv, filename1, '-append', 'delimiter', '');
dlmwrite(save_location_csv, particle_numbers, '-append', 'coffset', 1);
else
    end;

