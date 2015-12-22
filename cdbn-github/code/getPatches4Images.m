%��ȡһ���ļ����µ�����.jpg��Ӧ��patches,��ÿ��jpg�ļ�subsample��batch_size��[onepatchrow,onepatchcol]��С��patch
%�������ﷵ�ؽ���Ǹ��ĸ�ά�ȵ�����:[onepatchrow,onepatchcol,batch_size,imagenumbersl
function imdata_batch=getPatches4Images(fpath,batch_size,filtersize,onepatchrow,onepatchcol)
%y = randsample(n,k,replacement) or y = randsample(population,k,replacement) returns a sample 
    %taken with replacement if replacement is true, or without replacement if replacement is false. The default is false.
    images_all=sample_images_all(fpath);
    for i = 1:length(images_all)%��ÿ��ͼƬ��ȡbatch_size��batch_ws��С��ͼƬ(����patch��С)
        imdata = images_all{i};
        rows = size(imdata,1);
        cols = size(imdata,2);
        
        for batch=1:batch_size%�����һ��imbatch,��һ��ͼƬ����һ��ͼƬsubsample��batch_size��70*70��patch,����ÿ��batch��һ��70*70��patch
            rowidx = ceil(rand*(rows-2*filtersize-onepatchrow))+filtersize + [1:onepatchrow];%ws�Ǿ���˴�С
            colidx = ceil(rand*(cols-2*filtersize-onepatchcol))+filtersize + [1:onepatchcol];
            batchdata(:,:,batch) = imdata(rowidx, colidx);%��imdata��һ�Ŵ�����ͼƬ)ȡ��patch
            patch_k=batchdata(:,:,batch);
            batchdata(:,:,batch) = batchdata(:,:,batch) - mean(patch_k(:));%��ȥ��ֵ
        end
        imdata_batch(:,:,:,i)=batchdata;
    end
end