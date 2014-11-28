%%
%   Author: ����
%   ʵ������ƪ�����е��㷨��Ŀ����Ϊ�˼���ͼ���еĹ��շ���
%   A. Pentland, "Finding the iliuminant direction," J. Opt. Soc.Amer., vol. 72, no. 4, 1982.
%   2014��11��18�� 11:07:08
%   ������
%       image��ͼ���Ӧ����
%       region_size��������շ���ʱ����������ı߳�
%   ����ֵ��
%       direction������ÿһ��region��һ����Դ��������direction�Ĵ�СΪ(int32((size(image, 1) - 2) / region_size), int32((size(image, 2) - 2) / region_size), 3)
%   �쳣��
%       direction = 0

%%
%function [direction] = illuminant_direction(image, region_size)

region_size = 100;
image = toutatis;
%   ���������
if region_size < 3 || region_size > size(image, 1) || region_size > size(image, 2) || size(image, 1) < 3 || size(image, 2) < 3 || size(image, 1) ~= size(image, 2)
    direction = 0;
    return;
end

if length(size(image)) > 2
    image = rgb2gray(image);
end

%   ���ɰ˷���prewitt���ӣ�Ҳ����8���������еľ���
temp = fspecial('prewitt');
prewitt = zeros(3, 3, 4);
for i = 1: 4
    prewitt(:, :, i) = temp;
    temp = imrotate(temp, 45, 'crop');
end

%   ����������˹����
laplacian = fspecial('laplacian');


%   �洢����ֵ��ÿ�������Ӧһ����Դ����
direction = zeros(int32((size(image, 1) - 2) / region_size), int32((size(image, 2) - 2) / region_size), 3);

%   beta����ͼ���ϵİ˸�����ÿ������Ϊ��λ����
beta = [-1, 0; -1, -1; 0, -1; 1, -1];%; 1, 0; 1, 1; 0, 1; -1, 1];
for i = 1: 4
    beta(i, :) = beta(i, :)/norm(beta(i, :));
end
beta = inv(beta' * beta) * beta';
%[x~, y~] = inv(beta' * beta) * beta' *

%   ���ѭ��������ÿ�������dI��dI2,����ÿ������Ĺ��շ��򲢴���direction
for i = 2 : region_size : size(image, 1) - region_size
    for j = 2  : region_size : size(image, 2) - region_size
        %   ��ѭ����Ϊ��Ӧһ������
        %   gradient��ӦdI��gradient2��ӦdI2
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
        %   ��ʱgradient��ӦE(dI)
        gradient = gradient / (region_size^2);
        %   ��ʱgradient2��ӦE(dI2)
        gradient2 = gradient2 / (region_size^2);
        
        x_y_ = beta * gradient';
        %   k����Ϊ����
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

