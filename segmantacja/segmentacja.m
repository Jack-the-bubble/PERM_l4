clear all;

I= imread('../main.jpg');

%%wyodrebnienie koloru r

% I = imresize(I,0.5);
% I = im2double(I);
% imshow(I);
% 
% 
% [BW_r,maskedRGBImage_r] = createMask_r(I);
% BW_r_thres = rgb2gray(maskedRGBImage_r);
% % BW_r_thres = double(imbinarize(maskedRGBImage_r));
% % BW_r = rgb2grey(maskedRGBImage_r);
% 
% [BW_seg_r,maskedImage_r] = segment_r(BW_r_thres);
% 
% imshow(maskedImage_r);
% 
% [BW_out,properties_r] = filterRegions_r(BW_in)
% 
% %wyodrebnienie koloru y













% 
% 
% %figure(1)
% %imshow(I);
% I = imresize(I,0.5);
% I = im2double(I);
% [B, Mask] = createMask(I);
% %figure(2)
% %imshow(B)
% % pozbycie sie niechcianych kropek i szumow
% s_closing = strel('disk',3);
% afterClosing = imclose(B,s_closing);
% s_opening = strel('disk',4);
% afterOpening = imopen(afterClosing,s_opening);
% %figure(3)
% %imshow(afterOpening)
% %imwrite(afterOpening,'myGrayMask.png');
% [BW_out,properties] = filterRegions(afterOpening);
% 
% circ_x = [];
% circ_y = [];
% circ_areas = [];
% major_axis = [];
% minor_axis = [];
% 
% % nieefektywne filtrowanie okregow
% for i=1:1:length(properties)
%     ratio = properties(i).Area/(properties(i).Perimeter)^2;
%     if  ratio > 0.1/4*3.14
%         minor_axis = [minor_axis; properties(i).MinorAxisLength]
%         major_axis = [major_axis; properties(i).MajorAxisLength]
%         circ_areas = [circ_areas; properties(i).Area]
%         circ_x = [circ_x; properties(i).Centroid(1)];
%         circ_y = [circ_y; properties(i).Centroid(2)];
%     end
% end
% 
% % najwieksze koło
% [max_circ_area, id_max_circ] = max(circ_areas);
% % średnica najwiekszego
% diameter = mean([minor_axis(id_max_circ) major_axis(id_max_circ)],2);
% % promien najwiekszego
% real_radius = 78;
% radius = diameter/2; % to jest rowne 78 mm
% center = [circ_x(id_max_circ) circ_y(id_max_circ)];
% 
% figure(1)
% imshow(afterOpening);
% hold on;
% scatter(circ_x,circ_y,'filled');
% hold off;
% hold on
% viscircles(center,radius);
% hold off
% txt = sprintf('radius = %g',real_radius);
% text(center(1),center(2),txt,'Color','blue','FontSize',12)
%figure(1)
%imshow(I);
I = imresize(I,0.3);
I = im2double(I);

[B, Mask] = createMask(I);
%figure(2)
%imshow(B)
% pozbycie sie niechcianych kropek i szumow
s_closing = strel('disk',4);
afterClosing = imclose(B,s_closing);
s_opening = strel('disk',2);
afterOpening = imopen(afterClosing,s_opening);
%figure(3)
%imshow(afterOpening)
%imwrite(afterOpening,'myGrayMask.png');
[BW_out,properties] = filterRegions(afterOpening);








circ_x = [];
circ_y = [];
circ_areas = [];
major_axis = [];
minor_axis = [];

pens_centroids = [];
pens_orientations = [];
pens_boxes = [];
pens_major_axis = [];
pens_minor_axis = [];

% nieefektywne filtrowanie okregow
for i=1:1:length(properties)
    ratio = properties(i).Area/(properties(i).Perimeter)^2;
    if  ratio > 0.1/4*3.14
        minor_axis = [minor_axis; properties(i).MinorAxisLength];
        major_axis = [major_axis; properties(i).MajorAxisLength];
        circ_areas = [circ_areas; properties(i).Area]
        circ_x = [circ_x; properties(i).Centroid(1)];
        circ_y = [circ_y; properties(i).Centroid(2)];
    else
        pens_centroids = [pens_centroids; properties(i).Centroid];
        pens_boxes=[pens_boxes; properties(i).BoundingBox];
        pens_minor_axis = [pens_minor_axis; properties(i).MinorAxisLength];
        pens_major_axis = [pens_major_axis; properties(i).MajorAxisLength];
        pens_orientations = [pens_orientations; properties(i).Orientation];
    end
end

%KOŁA----------------------------------------------------
% najwieksze koło
[max_circ_area, id_max_circ] = max(circ_areas);
% średnice
diameter = mean([minor_axis major_axis],2);
% promienie
radiuses = diameter/2;
% maksymalna średnica
max_diameter = max(diameter);
% maksymalny promień
max_radius = max_diameter/2;
% promien najwiekszego okregu w mm
real_max_radius = 78/2;
% ile mm ma jeden pixel
px2mm = real_max_radius/max_radius;;
% srodek najwiekszego okregu
center = [circ_x(id_max_circ) circ_y(id_max_circ)];

% figure(1)
% % imshow(afterOpening);
% hold on;
% for i=1:1:length(circ_areas)
%    scatter(circ_x(i),circ_y(i),'filled');
%    viscircles([circ_x(i) circ_y(i)],radiuses(i));
%    radius = round(radiuses(i)*px2mm);
%    txt = sprintf('R = %g mm',radius);
%    text(circ_x(i),circ_y(i),txt,'Color','green','FontSize',10)
% end
% hold off;
% hold on;
%--------------------------------------------------------


%DŁUGOPISY-----------------------------------------------
for i=1:1:length(pens_centroids)
   scatter(pens_centroids(i,1),pens_centroids(i,2),'filled');
   pen_minor_axe = round(pens_minor_axis(i)*px2mm);
   pen_major_axe = round(pens_major_axis(i)*px2mm);
   pen_orientation = round(pens_orientations(i),2);
   txt = sprintf('width: %g mm \n length: %g mm \n orient: %g deg',pen_minor_axe,pen_major_axe,pen_orientation);
   text(pens_centroids(i,1),pens_centroids(i,2),txt,'Color','green','FontSize',10)
end
%--------------------------------------------------------

%wyodrebnienie pojedynczego konturu----------------------
%1. wytnij kawalek obrazu
% imshow(BW_out)

% wyodrebnienie obiektu z obrazu
pen = 5
box = pens_boxes(pen, :);
im_x = box(1);
im_y = box(2);
im_len = box(3);
im_wid = box(4);
BW_help = BW_out(im_y:im_y+im_wid, im_x:im_x+im_len);
% imshow(BW_help)
% obroc go, zeby byl rownolegle do osi X
deg = -pens_orientations(pen);




image_rot = imrotate(BW_help, deg, 'bicubic')

image_rot_d = double(image_rot)
imshow(image_rot_d)

% wytnij koncowki w zaleznosci od zadanych procentow
siz = 0.3
im_proc = siz*size(image_rot, 1)
image_rot = [image_rot(:, 1:im_proc) image_rot(:, end-im_proc:end)];
probes = sum(image_rot)
S = skewness(probes)


% pokaż obrocony obraz
image_rot_d = double(image_rot)
% image_rot_d = imgaussfilt(image_rot_d)
imshow(image_rot_d)
