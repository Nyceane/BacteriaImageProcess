%This script is written to deal with one whole image: to extract patches
%from an image, patch by patch, I mean, combining all the patches can cover
%the whole image
%here I make a stupid mistake: I first extract a patch rowwise, but in
%fact, the other place are columnwise (), sow I have to modify the code now. 
function [patchset,precomp] = getPatchesCoverOneImage(fpath,patchrows,patchcols)

if nargin==1
    patchrows=16;
    patchcols=16;
end

I=imread(fpath);
if size(I,3)>1
    I=rgb2gray(I);
end
ratio = min([512/size(I,1), 512/size(I,2), 1]);
if ratio<1
    I = imresize(I, [round(ratio*size(I,1)), round(ratio*size(I,2))], 'bicubic');
end

imshow(I);

[rows,cols]=size(I);

numofpatches=floor(rows/patchrows)*floor(cols/patchcols);

%��һ��patch����һ��vector������patches�����һ����,һ��ͼƬ��������ȡnumofpatches��patch
patchset=zeros(numofpatches,patchrows*patchcols);

num=0;%����patch�ĸ���

for i=1:patchrows:(rows-patchrows+1)%��ֹ��Խ�߽�
    for j=1:patchcols:(cols-patchcols+1)
        %��(i,j)Ϊ���Ͻǵ�*30��patch
        num=num+1;%��num��patch
        %At first, I extract the patch rowwise, but the other place are
        %colwise, so I have to modify the code, it is rowwise
%         for r=i:i+patchrows-1%matlab���for �Ǵ�head��tail��included��
%             for c=j:j+patchcols-1
%                 patchset(num,(r-i)*patchcols+(c-j+1))=I(r,c);
%             end
%         end
        patch=I(i:i+patchrows-1,j:j+patchcols-1);
        patchset(num,:)=patch(:);%columnwise
    end
end
patchset=patchset';%dimension*numģʽ
save('..\results\maskImage\patches','patchset');
[patchset,precomp]=whiten(patchset);
save('..\results\maskImage\whitenpatches','patchset','precomp');
end

