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
%   ���������
% if region_size < 3 || region_size > size(image, 1) || region_size > size(image, 2) || size(image, 1) < 3 || size(image, 2) < 3 || size(image, 1) ~= size(image, 2)
%     direction = 0;
%     return;
% end

% if length(size(image)) > 2
%     image = rgb2gray(image);
% end

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
direction = zeros(1, 3);

%   beta����ͼ���ϵİ˸�����ÿ������Ϊ��λ����
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
%   ��ʱgradient��ӦE(dI)
gradient = gradient / (width * height);
%   ��ʱgradient2��ӦE(dI2)
gradient2 = gradient2 / (width * height);

x_y_ = beta * gradient';
%   k����Ϊ����
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

