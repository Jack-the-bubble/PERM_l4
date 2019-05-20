I= imread('../main.jpg');
imshow(I);
I = imresize(I,0.5);
I = im2double(I);
createMask(I)
%I = rgb2gray(I);
%imshow(I);
%I = edge(I,'Canny',0.3);
%imshow(I);
%imcontour(I)
% size(I);
% I2 = imcrop(I,[0 120 640 270]);
% I3=rgb2gray(I2);
% I4 = imbinarize(I3);
% %[C,h] = imcontour(I4);
% %m = moment(C,2);
% I5 = imcomplement(I4);
% stats = regionprops(I5,'Centroid');
% centroids = cat(1, stats.Centroid);
% figure(1)
% imshow(I5)
% hold on
% plot(centroids(:,1), centroids(:,2), 'b*')
% hold off
