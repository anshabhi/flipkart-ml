T = readtable('test.csv');
% Read in a color demo image.
folder = '..\FlipkartGridStage2DataSetImages\images';
for k = 1:size(T)
baseFileName = T(k,1).image_name; %get the file name from test.csv file
% Get the full filename, with path prepended.
fullFileName = char(fullfile(folder, baseFileName));
k
I = imread(fullFileName); %Read in the image
y = I; % Create a copy of original image
%I = rgb2gray(I); Convert image to gray
[rows, columns, numberOfColorBands] = size(I);
if numberOfColorBands > 1
  % It's not really gray scale like we expected - it's color.
  % Convert it to gray scale by taking only the green channel.
  I = I(:, :, 3); % Take blue channel.
end 

[~, threshold] = edge(I, 'sobel');
fudgeFactor = .3;
BWs = edge(I,'sobel', threshold * fudgeFactor);


se90 = strel('line', 3, 90);
se0 = strel('line', 3, 0);

BWsdil = imdilate(BWs, [se90 se0]);


BWdfill = imfill(BWsdil, 'holes');


BWnobord = imclearborder(BWdfill, 4);

seD = strel('diamond',1);
BWfinal = imerode(BWnobord,seD);
BWfinal = imerode(BWfinal,seD);
%figure, imshow(BWfinal), title('segmented image');

rp = regionprops(BWfinal, 'BoundingBox', 'Area');

%// Step #4
area = [rp.Area].';
[~,ind] = max(area);
a1=max(area);
if(~isempty(ind))
bb1 = rp(ind).BoundingBox;
end
hold on;
%imshow(y);
%rectangle('Position', bb1, 'EdgeColor', 'red');
%x = input (' ')  
im_thresh = rgb2gray(y) < 100;

%sum100 = sum(im_thresh100(:));
%// Step #2
%if (sum100>sum170)
%im_thresh2 = imclearborder(im_thresh100);
%else
im_thresh2 = imclearborder(im_thresh);
%end

%// Step #3
rp = regionprops(im_thresh2, 'BoundingBox', 'Area');

%// Step #4
area = [rp.Area].';
[~,ind] = max(area);
a2 = max(area);
if(~isempty(ind))
bb2 = rp(ind).BoundingBox;
%rectangle('Position', bb2, 'EdgeColor', 'blue');
%hold off;
end
rgbImage = y;
% Get the dimensions of the image.  numberOfColorChannels should be = 3.
[rows, columns, numberOfColorChannels] = size(rgbImage);
% Display the original color image.

% Enlarge figure to full screen.
hsvImage = rgb2hsv(rgbImage);
sImage = hsvImage(:, :, 2);

% Threshold.
mask = sImage > 0.1;
% Extract biggest blob.
mask = bwareafilt(mask, 1);

% Fill holes.
mask = imfill(mask,8, 'holes');

% Get bounding box.
props = regionprops(mask, 'BoundingBox','Area');
if(~(isempty(props)))
bb3 = props.BoundingBox;
a3 = props.Area;

end
maxa = max([a1,a2,a3]);
if (maxa == a1)
    bb = bb1;
elseif (maxa == a2)
    bb = bb2;
else
    bb = bb3;
end
%imshow(y);
%rectangle('Position', bb1, 'EdgeColor', 'blue');
%rectangle('Position', bb2, 'EdgeColor', 'red');
%rectangle('Position', bb3, 'EdgeColor', 'green');

 T(k,2) = cellstr(num2str(bb(1)-0.5));
t = bb(1) + bb(3)-0.5;
T(k,3) = cellstr(num2str(t));
T(k,4) = cellstr(num2str(bb(2)-0.5));
t = bb(2) + bb(4)-0.5;
T(k,5) = cellstr(num2str(t));
%x = input(' ');
end


writetable(T,'result.csv');