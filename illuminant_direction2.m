%%
%   Author: 孙雷
%   实现了这篇文章中的算法，目的是为了计算图像中的光照方向
%   A. Pentland, "Finding the iliuminant direction," J. Opt. Soc.Amer., vol. 72, no. 4, 1982.
%   2014年11月18日 11:07:08
%   参数：
%       image：图像对应矩阵
%       region_size：计算光照方向时正方形区域的边长
%   返回值：
%       direction：对于每一个region有一个光源方向，所以direction的大小为(int32((size(image, 1) - 2) / region_size), int32((size(image, 2) - 2) / region_size), 3)
%   异常：
%       direction = 0

%%
%function [direction] = illuminant_direction(image, region_size)

image = rgb2gray(t2);
imshow(t_image);
%[y, x, width, height];
rect = getrect;

y = int32(rect(1, 1));
x = int32(rect(1, 2));
width = int32(rect(1, 3));
height = int32(rect(1, 4));


% image = toutatis;
% %   错误的输入
% if region_size < 3 || region_size > size(image, 1) || region_size > size(image, 2) || size(image, 1) < 3 || size(image, 2) < 3 || size(image, 1) ~= size(image, 2)
%     direction = 0;
%     return;
% end

% if length(size(image)) > 2
%     image = rgb2gray(image);
% end

%   生成八方向prewitt算子，也就是8个三行三列的矩阵
temp = fspecial('prewitt');
prewitt = zeros(3, 3, 8);
for i = 1: 8
    prewitt(:, :, i) = temp;
    temp = imrotate(temp, 45, 'crop');
end

%   生成拉普拉斯算子
laplacian = fspecial('laplacian');


%   存储返回值，每个区域对应一个光源向量
% direction = zeros(int32((size(image, 1) - 2) / region_size), int32((size(image, 2) - 2) / region_size), 3);

%   beta代表图像上的八个方向，每个方向化为单位向量
beta = [-1, 0; -1, -1; 0, -1; 1, -1; 1, 0; 1, 1; 0, 1; -1, 1];
for i = 1: 8
    beta(i, :) = beta(i, :)/norm(beta(i, :));
end
beta = inv(beta' * beta) * beta';

gradient1 = zeros(height, width, 8);
gradient2 = zeros(height, width, 8);

for i = 1: 8
    for j = 2: height - 1
        for k = 2: width - 1
%             region = double([image(j + height -  1, k - 1), image(j + height - 1, k), image(j + height - 1, k + 1); image(j + height, k), image(j + height, k - 1), image(j + height, k + 1); image(j + height - 1, k - 1), image(j + height + 1, k), image(j + height + 1, k + 1)]);
            region = double(image(j + x -  1: j + x + 1, k + y - 1: k + y + 1));
            gradient1(j, k, i) = sum(sum(prewitt(:, :, i) .* region));
        end
    end
end

EdI = double(sum(sum(sum(gradient1)))) / double((height - 2)) / double((width - 2)) / 8.0;

% for i = 1: 8
%     gradient1(:, :, i) = gradient1(:, :, i) .* gradient1(:, :, i);
% end
% 
% EdI2 = double(sum(sum(sum(gradient1)))) / double((height - 2)) / double((width - 2)) / 8.0;
% 
% 
% k = sqrt(EdI2 - EdI^2);


