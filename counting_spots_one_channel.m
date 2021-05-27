%{
Provide the exact directory location and the file name in line 20.  A wild
characcter can be added at specific locations for consecutive processing
of multiple files.  For example replacing 1 to the right of _s with a *
will allow processing of all files for different stage positions.
These two commands will allow you to obtain the file location - 
[file,path] = uigetfile;file_location=cat(2,path,file)

The program assumes that the file names consists of four parts - as in
descripter_wavelength_position.tif, for example, cs1-1_w1DIC Camera_s1.tif . 
In this example, the string left to the first underscore is the descriptor fo 
your experiment, between the two underscores is the wavelength, and to the 
right of the second underscore but befor the suffix .tif is the position.  
The last element is the file type .tif.

In line 21 provide the directory where
the figue with circles around the spots are drawn are saved. In line 22 
provide the directory where the results should be saved (as a .csv file).
%}
file_location='C:\Users\imaging\Desktop\Test_10_2_19\cs1-2_w4Cy5 Camera_s1.TIF';
save_location_matlab_figures='C:\Users\imaging\Desktop\Test_10_2_19\saved matlab figures';
save_location_csv='C:\Users\imaging\Desktop\Test_10_2_19\particle_numbers.csv';
files = dir(file_location);
for i=1:size(files,1);
    
filename=files(i).name;
I=imread(filename,8);
info = imfinfo(filename);
ims=zeros([size(I),(numel(info))]);
for k=1:1:(numel(info)); 
        ims(:,:,k)=imread(filename,(k)); 
    end;
imsd = medianfilter(double(ims));
clear ims;
lapims1 = laplace(imsd);
lapims1 = lapims1/max(lapims1(:));
im1 = max(lapims1,[],3);
 
%In case the image is very dark, determine contrast parmaters using imtool and replace teh first and second
%numbers within [] with the low and high limits.
%imtool(im1);
%p1 = input('image1_low ');p2 = input('image1_high ');
im1_adjust=imadjust(im1, stretchlim(im1),[]);
fprintf('Draw rectangle with mouse for thresholding                %g\n');
figure(1); imshow(im1_adjust);
R = getrect;
test = imcrop(im1,R);
figure(2); surf(test);
threshx_low = input('Lower Threshold? ');
threshx_high = input('Upper Threshold? ');
L = sliceall(lapims1,threshx_low);
[lab1,n1] = bwlabeln(L);
s = regionprops(lab1,'Area');
areas1 = [s.Area];
bw11 = ismember(lab1,find(areas1 > 10));
bw21 = ismember(lab1,find(areas1 > 800));
[lab12,n11] = bwlabeln(bw11);
[lab13,n12] = bwlabeln(bw21);
firstthresholdparticles = xor(lab12,lab13);
clear lab1; clear lab12; clear lab13;
previous = firstthresholdparticles; 
clear firstthresholdparticles; clear bw11; clear bw21;
 
for i=1:7
   thresh = threshx_low+(((threshx_high - threshx_low)/7)*i);
   L_current = sliceall(lapims1,(thresh));
   [lab_current] = bwlabeln(L_current);
   bw_current = ismember(lab_current,find(areas1 > 800));
   [lab_current_big] = bwlabeln(bw_current);
   upto_current_thresh = xor(lab_current,lab_current_big);%removes bigger particles
   current_thresh = upto_current_thresh & (~previous);%removes particles seen with previous threholds
   upto_current_segregated = previous | current_thresh; %adds to the previous previous
   previous= upto_current_segregated;
end
[laballx,n_allx] = bwlabeln(previous);
s = regionprops(laballx,'Centroid');
centers1 = cat(1,s.Centroid);
clear upto_current_segregated; clear upto_current_thresh;clear previous;
clear lab_current_big; clear lab_current;
 
figure(3);
hold off;
imshow(im1_adjust);
hold on;
 
%load cell boundaries
filename2 = replaceBetween(filename,'_','_','wavelength');
load(cat(2,extractBefore(filename2,'.'),'.mat'));

%Count spots within cells
centers1x_withincell = cell(1,size(cell_boundaries,1));centers1y_withincell = cell(1,size(cell_boundaries,1));
particle_numbers=zeros(size(cell_boundaries,1),4);
 
for i = 1:size(cell_boundaries,2);
    cell_boundaries_1 = cell_boundaries{i};
    if size(centers1,1) == 0; particle_numbers(i,2)=0;
    else
        withincell_centers1 = inpolygon(centers1(:,1),centers1(:,2),cell_boundaries_1(:,2),cell_boundaries_1(:,1));
        centers1x = centers1(:,1); centers1y = centers1(:,2);
        centers1x_withincell{1,i} = centers1x(withincell_centers1);
        centers1y_withincell{1,i} = centers1y(withincell_centers1);
        particle_numbers(i,2)=size(centers1x_withincell{1,i},1);
        plot(centers1x_withincell{1,i},centers1y_withincell{1,i}, 'yo' ,'markersize',15);
        end
    
    particle_numbers(i,1)=i;
    particle_numbers(i,3)=threshx_low;
    particle_numbers(i,4)=threshx_high;
    plot(cell_boundaries_1(:,2),cell_boundaries_1(:,1),'b', 'LineWidth', 2);
     text(mean(cell_boundaries_1(:,2)), mean(cell_boundaries_1(:,1)), ['\fontsize{25}', '\color{cyan}' num2str(i)]);
end
 
%saving
m=input('Do you want to save data, y/n [Y]:','s');
if m=='y';
    savefile = cat(2, filename);
g=fullfile(save_location_matlab_figures, savefile);
saveas(gcf, cat(2,g, '.fig'), 'fig');

end

dlmwrite(save_location_csv, filename, '-append', 'delimiter', '');
dlmwrite(save_location_csv, thresh,'-append', 'delimiter', '');
dlmwrite(save_location_csv, particle_numbers, '-append', 'coffset', 1);
clearvars -except files file_location save_location_matlab_figures save_location_csv;
    end;

