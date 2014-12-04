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

image = rgb2gray(t2);
imshow(t_image);
%[y, x, width, height];
rect = getrect;

y = int32(rect(1, 1));
x = int32(rect(1, 2));
width = int32(rect(1, 3));
height = int32(rect(1, 4));


% image = toutatis;
% %   ���������
% if region_size < 3 || region_size > size(image, 1) || region_size > size(image, 2) || size(image, 1) < 3 || size(image, 2) < 3 || size(image, 1) ~= size(image, 2)
%     direction = 0;
%     return;
% end

% if length(size(image)) > 2
%     image = rgb2gray(image);
% end

%   ���ɰ˷���prewitt���ӣ�Ҳ����8���������еľ���
temp = fspecial('prewitt');
prewitt = zeros(3, 3, 8);
for i = 1: 8
    prewitt(:, :, i) = temp;
    temp = imrotate(temp, 45, 'crop');
end

%   ����������˹����
laplacian = fspecial('laplacian');


%   �洢����ֵ��ÿ�������Ӧһ����Դ����
% direction = zeros(int32((size(image, 1) - 2) / region_size), int32((size(image, 2) - 2) / region_size), 3);

%   beta����ͼ���ϵİ˸�����ÿ������Ϊ��λ����
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


