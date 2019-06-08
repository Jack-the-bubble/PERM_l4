clear all;

I= imread('../main.jpg');
I = imresize(I,0.3);
I_hsv = rgb2hsv(I);
[B2,Mask1] = createMask_ycbcr(I);
B = B2;
% pozbycie sie niechcianych kropek i szumow
s_closing = strel('disk',2);
afterClosing = imclose(B,s_closing);
[BW_out,properties] = filterRegions(afterClosing);

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
pens_eccentricity = [];
pens_perimeter = [];
% filtrowanie okregow

for i=1:1:length(properties)
    if properties(i).Area > 40 
        ratio = properties(i).Area/(properties(i).Perimeter)^2;
        if  ratio > 0.1/4*3.14
            minor_axis = [minor_axis; properties(i).MinorAxisLength];
            major_axis = [major_axis; properties(i).MajorAxisLength];
            circ_areas = [circ_areas; properties(i).Area];
            circ_x = [circ_x; properties(i).Centroid(1)];
            circ_y = [circ_y; properties(i).Centroid(2)];
        elseif (properties(i).Area < 3500) && (afterClosing(floor(properties(i).Centroid(2)), floor(properties(i).Centroid(1))))
            pens_centroids = [pens_centroids; properties(i).Centroid];
            pens_boxes=[pens_boxes; properties(i).BoundingBox];
            pens_minor_axis = [pens_minor_axis; properties(i).MinorAxisLength];
            pens_major_axis = [pens_major_axis; properties(i).MajorAxisLength];
            pens_orientations = [pens_orientations; properties(i).Orientation];
            pens_eccentricity = [pens_eccentricity; properties(i).Eccentricity];
        end
    end
end

%CIRCLES----------------------------------------------------
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

%wyodrebnienie pojedynczego konturu----------------------
% wyodrebnienie obiektu z obrazu i obliczanie orientacji
for i =1: length(pens_boxes)
    
    pen = i;
    box = pens_boxes(pen, :);
    im_x = floor(box(1));
    im_y = floor(box(2));
    im_len = floor(box(3));
    im_wid = floor(box(4));
    BW_help = BW_out(im_y:im_y+im_wid, im_x:im_x+im_len);
    % imshow(BW_help)
    % obroc go, zeby byl rownolegle do osi X
    deg = -pens_orientations(pen);


    image_rot = imrotate(BW_help, deg, 'bicubic');
%     figure(2)
%     image_rot_d = double(image_rot);
%     imshow(image_rot_d);
%     tekst = sprintf("this figure's eccentricity is %d", pens_eccentricity(i));
%     disp(tekst);
    k = size(image_rot);

% wytnij elementy, na gorze i u dolu dlugopisu, zeby uniknac fragmentow
% innych obiektow

% wyznacz najgrubsze miejsce obiekty i do takiej wielkosci przytnij
    pom  = floor(max(sum(image_rot))/2+1);
    ver_trim = floor(0.2*k(1));
    image_rot = image_rot(floor((k(1)/2-pom)):floor((k(1)/2+pom)), :);
    
%     metoda nr 1 - obliczanie skosnosci
%     probes = sum(image_rot);
%     S = skewness(probes);
%     angles = zeros(17, 1);    
    
%     sprawdz po ktorej stronie jest wiecej pikseli - metoda nr 2
    pix_count_l = sum(sum(image_rot(:, 1:floor(k(2)/2))));
    pix_count_r = sum(sum(image_rot(:, floor(k(2)/2+1):end)));
    S = pix_count_l-pix_count_r;
    
    

    point_thresh = 10;
    
    if abs(S) > point_thresh
    if S > 0
        pens_orientations(i) = -deg;
%         tekst = sprintf('ksztalt %d po prawej, kat %d', i, angles(i));
%         txt = sprintf('po prawej');
    else
        pens_orientations(i) = 180-deg;
%         tekst = sprintf('ksztalt %d po lewej, kat %d', i, angles(i));
%         txt = sprintf('po lewej');
    end
%     disp(tekst);
    else
%         tekst = sprintf("nie wykryto koncowki dla obiektu %d", i);
        pens_orientations(i) = 0;
%         disp(tekst)
    end
    
%     figure(3)
%     imshow(image_rot_d)
end



% WYZNACZANIE KOLORU Z POMOCA HSV
circle_colors = [];
pens_colors = [];
%     thresholds
    white = 0.3;
    red = 0.8;
    green = 0.55;
    yellow = 0.3;
    min_orange = 0;
    orange = 0.1;
    blue = 0.7;
% circles-------------------------------------------------
for i = 1 : length(circ_x)
    y = floor(circ_x(i, 1))
    x = floor(circ_y(i, 1))

    if (I_hsv(x, y, 2) < white)
        %    sprawdzenie bialego 
        circle_colors = [circle_colors; "white"];
    else
        hue = I_hsv(x, y, 1);
        if (hue > min_orange) && (hue < orange)
            circle_colors = [circle_colors; "orange"];
        elseif (hue > red) && (hue < 1)
            circle_colors = [circle_colors; "red"];
        elseif (hue >= orange) && (hue < yellow)
            circle_colors = [circle_colors; "yellow"];
        elseif (hue >= yellow) && (hue < green)
            circle_colors = [circle_colors; "green"];
        elseif (hue >= green) && (hue < blue)
            circle_colors = [circle_colors; "blue"];
        else
            circle_colors = [circle_colors; "else"];
        end
    end
    

    
end

for i = 1: length(pens_centroids)
    if I_hsv(floor(pens_centroids(i, 2)), floor(pens_centroids(i, 1)), 2) < white
        pens_colors = [pens_colors ; "white"];
    else
        hue = I_hsv(floor(pens_centroids(i, 2)), floor(pens_centroids(i, 1)), 1);
        if (hue > 0) && (hue < orange)
            pens_colors = [pens_colors; "orange"];
        elseif (hue > red) && (hue < 1)
            pens_colors = [pens_colors; "red"];
        elseif (hue >= orange) && (hue < yellow)
            pens_colors = [pens_colors; "yellow"];
        elseif (hue >= yellow) && (hue < green)
            pens_colors = [pens_colors; "green"];
        elseif (hue >= green) && (hue < blue)
            pens_colors = [pens_colors; "blue"];
        else
            pens_colors = [pens_colors; "else"];
        end
    end
end

figure(1)
% imshow(afterClosing);
imshow(I);
hold on;
for i=1:1:length(circ_areas)
   scatter(floor(circ_x(i)),floor(circ_y(i)),'filled');
   viscircles([floor(circ_x(i)) floor(circ_y(i))],radiuses(i));
   radius = round(radiuses(i)*px2mm);
   col = circle_colors(i);
   txt = sprintf('R = %g mm \n color: %s',radius, col);
   text(floor(circ_x(i, 1)),floor(circ_y(i, 1)),txt,'Color','blue','FontSize',10)
end
hold off;
hold on;
%DUGOPISY-----------------------------------------------
for i=1:1:length(pens_centroids)
   scatter(pens_centroids(i,1),pens_centroids(i,2),'filled');
   pen_minor_axe = round(pens_minor_axis(i)*px2mm);
   pen_major_axe = round(pens_major_axis(i)*px2mm);
   pen_orientation = round(pens_orientations(i),2);
   col = pens_colors(i);
   txt = sprintf('id: %g \n width: %g mm \n length: %g mm \n orient: %g deg \n color: %s',i,pen_minor_axe,pen_major_axe,pen_orientation, col);
   text(floor(pens_centroids(i,1)),floor(pens_centroids(i,2)),txt,'Color','blue','FontSize',10)
end
