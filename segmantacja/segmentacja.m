I= imread('../main.jpg');
%figure(1)
%imshow(I);
I = imresize(I,0.5);
I = im2double(I);
[B, Mask] = createMask(I);
%figure(2)
%imshow(B)
% pozbycie sie niechcianych kropek i szumow
s_closing = strel('disk',3);
afterClosing = imclose(B,s_closing);
s_opening = strel('disk',4);
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

% nieefektywne filtrowanie okregow
for i=1:1:length(properties)
    ratio = properties(i).Area/(properties(i).Perimeter)^2;
    if  ratio > 0.1/4*3.14
        minor_axis = [minor_axis; properties(i).MinorAxisLength]
        major_axis = [major_axis; properties(i).MajorAxisLength]
        circ_areas = [circ_areas; properties(i).Area]
        circ_x = [circ_x; properties(i).Centroid(1)];
        circ_y = [circ_y; properties(i).Centroid(2)];
    end
end

% najwieksze koło
[max_circ_area, id_max_circ] = max(circ_areas);
% średnica najwiekszego
diameter = mean([minor_axis(id_max_circ) major_axis(id_max_circ)],2);
% promien najwiekszego
real_radius = 78;
radius = diameter/2; % to jest rowne 78 mm
center = [circ_x(id_max_circ) circ_y(id_max_circ)];

figure(1)
imshow(afterOpening);
hold on;
scatter(circ_x,circ_y,'filled');
hold off;
hold on
viscircles(center,radius);
hold off
txt = sprintf('radius = %g',real_radius);
text(center(1),center(2),txt,'Color','blue','FontSize',12)

