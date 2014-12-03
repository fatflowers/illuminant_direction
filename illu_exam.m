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
t_image = rgb2gray(t2);
imshow(t_image);
%[y, x, width, height];
rect = getrect;

y = rect(1, 1);
x = rect(1, 2);
width = rect(1, 3);
height = rect(1, 4);

region_size = 100;
image = t_image(x: x + height, y: y + width);
%   错误的输入
% if region_size < 3 || region_size > size(image, 1) || region_size > size(image, 2) || size(image, 1) < 3 || size(image, 2) < 3 || size(image, 1) ~= size(image, 2)
%     direction = 0;
%     return;
% end

% if length(size(image)) > 2
%     image = rgb2gray(image);
% end

%   生成八方向prewitt算子，也就是8个三行三列的矩阵
temp = fspecial('prewitt');
prewitt = zeros(3, 3, 4);
for i = 1: 4
    prewitt(:, :, i) = temp;
    temp = imrotate(temp, 45, 'crop');
end

%   生成拉普拉斯算子
laplacian = fspecial('laplacian');


%   存储返回值，每个区域对应一个光源向量
direction = zeros(1, 3);

%   beta代表图像上的八个方向，每个方向化为单位向量
beta = [-1, 0; -1, -1; 0, -1; 1, -1];%; 1, 0; 1, 1; 0, 1; -1, 1];
for i = 1: 4
    beta(i, :) = beta(i, :)/norm(beta(i, :));
end
beta = inv(beta' * beta) * beta';
%[x~, y~] = inv(beta' * beta) * beta' *

gradient = double(zeros(1, 4));
gradient2 = 0;
for k = 2 : height - 1
    for l = 2 : width - 1
        region = double([image(k - 1, l - 1), image(k - 1, l), image(k - 1, l + 1); image(k, l), image(k, l - 1), image(k, l + 1); image(k - 1, l - 1), image(k + 1, l), image(k + 1, l + 1)]);
        for m = 1: 4
            gradient(1, m) = gradient(1, m) + sum(sum(region .* prewitt(:, :, m)));
        end


        gradient2 = gradient2 + sum(sum(region .* laplacian));
    end
end
%   此时gradient对应E(dI)
gradient = gradient / (width * height);
%   此时gradient2对应E(dI2)
gradient2 = gradient2 / (width * height);

x_y_ = beta * gradient';
%   k可能为复数
if gradient2 - mean(gradient)^2 > 0
    k = sqrt(gradient2 - mean(gradient)^2);
else
    k = sqrt(mean(gradient)^2 - gradient2);
end


direction(1, 1) = x_y_(1, 1) / k;
direction(1, 2) = x_y_(2, 1) / k;
direction(1, 3) = sqrt(1 - (x_y_(1, 1) / k)^2 - (x_y_(2, 1) / k)^2);
%     end
% end

