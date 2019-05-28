I= imread('../main.jpg');
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

figure(1)
imshow(afterOpening);
hold on;
for i=1:1:length(circ_areas)
   scatter(circ_x(i),circ_y(i),'filled');
   viscircles([circ_x(i) circ_y(i)],radiuses(i));
   radius = round(radiuses(i)*px2mm);
   txt = sprintf('R = %g mm',radius);
   text(circ_x(i),circ_y(i),txt,'Color','green','FontSize',10)
end
hold off;
hold on;
%--------------------------------------------------------


%DŁUGOPISY-----------------------------------------------
for i=1:1:length(pens_centroids)
   scatter(pens_centroids(i,1),pens_centroids(i,2),'filled');
   pen_minor_axe = round(pens_minor_axis(i)*px2mm);
   pen_major_axe = round(pens_major_axis(i)*px2mm);
   pen_orientation = round(pens_orientations(i),2);
   txt = sprintf('id: %g \n width: %g mm \n length: %g mm \n orient: %g deg',i,pen_minor_axe,pen_major_axe,pen_orientation);
   text(pens_centroids(i,1),pens_centroids(i,2),txt,'Color','green','FontSize',10)
end
%--------------------------------------------------------

