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

region_size = 100;
image = toutatis;
%   错误的输入
if region_size < 3 || region_size > size(image, 1) || region_size > size(image, 2) || size(image, 1) < 3 || size(image, 2) < 3 || size(image, 1) ~= size(image, 2)
    direction = 0;
    return;
end

if length(size(image)) > 2
    image = rgb2gray(image);
end

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
direction = zeros(int32((size(image, 1) - 2) / region_size), int32((size(image, 2) - 2) / region_size), 3);

%   beta代表图像上的八个方向，每个方向化为单位向量
beta = [-1, 0; -1, -1; 0, -1; 1, -1];%; 1, 0; 1, 1; 0, 1; -1, 1];
for i = 1: 4
    beta(i, :) = beta(i, :)/norm(beta(i, :));
end
beta = inv(beta' * beta) * beta';
%[x~, y~] = inv(beta' * beta) * beta' *

%   这个循环计算了每个区域的dI和dI2,计算每个区域的光照方向并存入direction
for i = 2 : region_size : size(image, 1) - region_size
    for j = 2  : region_size : size(image, 2) - region_size
        %   此循环内为对应一个区域
        %   gradient对应dI，gradient2对应dI2
        gradient = double(zeros(1, 4));
        gradient2 = 0;
        for k = i : i + region_size
            for l = j : j + region_size
                region = double([image(k - 1, l - 1), image(k - 1, l), image(k - 1, l + 1); image(k, l), image(k, l - 1), image(k, l + 1); image(k - 1, l - 1), image(k + 1, l), image(k + 1, l + 1)]);
                for m = 1: 4
                    gradient(1, m) = gradient(1, m) + sum(sum(region .* prewitt(:, :, m)));
                end
%                 if sum(sum(region .* prewitt(:, :, m))) ~=0
%                     not0 = region .* prewitt(:, :, m);
%                     return;
%                 end
                
                gradient2 = gradient2 + sum(sum(region .* laplacian));
            end
        end
        %   此时gradient对应E(dI)
        gradient = gradient / (region_size^2);
        %   此时gradient2对应E(dI2)
        gradient2 = gradient2 / (region_size^2);
        
        x_y_ = beta * gradient';
        %   k可能为复数
%         if gradient2 - mean(gradient)^2 > 0
            k = sqrt(gradient2 - mean(gradient)^2);
%         else
%             continue;
%         end
       
        direction(int32(i / region_size) + 1, int32(j / region_size) + 1, 1) = x_y_(1, 1) / k;
        direction(int32(i / region_size) + 1, int32(j / region_size) + 1, 2) = x_y_(2, 1) / k;
        direction(int32(i / region_size) + 1, int32(j / region_size) + 1, 3) = sqrt(1 - (x_y_(1, 1) / k)^2 - (x_y_(2, 1) / k)^2);
    end
end

